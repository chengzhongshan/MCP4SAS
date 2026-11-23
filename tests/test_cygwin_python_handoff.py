"""Cygwin may hand off to native Windows SASPy; remote SAS paths stay remote."""
import contextlib
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT))
from MCP4SAS_Use_Python import cli
from MCP4SAS_Use_Python.dependencies import resolve_local


class CygwinPythonHandoffTests(unittest.TestCase):
    def probe(self,host,target,version=(3,12),saspy=True):
        info={'platform':target,'version':list(version),'prefix':'candidate-env','saspy':saspy}
        with patch.object(cli.sys,'platform',host),patch.object(cli.subprocess,'run',return_value=subprocess.CompletedProcess([],0,json.dumps(info),'notes')):
            return cli._probe_python(Path('python'))

    def test_cygwin_accepts_native_windows_saspy(self):
        self.assertIsNotNone(self.probe('cygwin','win32'))

    def test_platform_checks_remain_strict_elsewhere(self):
        self.assertIsNone(self.probe('linux','win32'))
        self.assertIsNone(self.probe('win32','cygwin'))
        self.assertIsNone(self.probe('darwin','linux'))

    def test_missing_saspy_and_old_python_still_rejected(self):
        self.assertIsNone(self.probe('cygwin','win32',saspy=False))
        self.assertIsNone(self.probe('cygwin','win32',version=(3,9)))

    def test_only_client_options_are_converted(self):
        code='filename x "/cygdrive/c/keep SAS source literal.txt";run;'
        args=['--code',code,'--file','/cygdrive/c/code one.sas','--output-prefix=/cygdrive/e/results',
              '--upload-file','/tmp/data.tsv','--download-file','/home/remote.tsv',
              '--dir4listing','/home/remote','--dir4local_sas_home','/home/remote-home']
        with patch.object(cli,'_cygpath',side_effect=lambda value,**kw:'WIN('+str(value)+')'):
            result=cli._windows_handoff_arguments(args)
        self.assertEqual(result[:2],['--code',code])
        self.assertEqual(result[3],'WIN(/cygdrive/c/code one.sas)')
        self.assertEqual(result[4],'--output-prefix=WIN(/cygdrive/e/results)')
        self.assertIn('WIN(/tmp/data.tsv)',result)
        self.assertIn('/home/remote.tsv',result)
        self.assertIn('/home/remote',result)
        self.assertEqual(result[-1],'/home/remote-home')

    def test_cygwin_configured_drive_path_is_normalized(self):
        with patch.object(cli.sys,'platform','cygwin'),patch.object(cli,'_cygpath',return_value='/cygdrive/c/Python/python.exe') as translate:
            candidate=cli._candidate_path('C:/Python/python.exe')
        translate.assert_called_once_with('C:/Python/python.exe')
        self.assertEqual(candidate,Path('/cygdrive/c/Python/python.exe'))

    def test_handoff_uses_selected_environment_without_exec_or_sas_replay(self):
        args=cli.parser().parse_args(['--code','proc print;run;'])
        candidate=Path('/cygdrive/c/Python/python.exe')
        with patch.object(cli.sys,'platform','cygwin'),patch.object(cli.sys,'argv',['runner.py','--code','proc print;run;']),\
             patch.object(cli.importlib.util,'find_spec',return_value=None),\
             patch.object(cli,'find_saspy_interpreter',return_value=(candidate,{'platform':'win32','prefix':'C:/Python'})),\
             patch.object(cli,'_cygpath',side_effect=lambda value,**kw:'WIN('+str(value)+')'),\
             patch.object(cli.os,'execv') as execv,patch.object(cli.subprocess,'run',return_value=subprocess.CompletedProcess([],0)) as run,\
             patch.dict(os.environ,{'PIPELINE_PYTHON_BIN':str(candidate),'SASPY_CFGFILE':'/cygdrive/c/sascfg.py','MCP4SAS_PYTHON_ENV_REEXEC':'','PYTHONPATH':''}),\
             contextlib.redirect_stderr(io.StringIO()):
            with self.assertRaises(SystemExit) as stopped:cli.ensure_saspy_environment(args)
            self.assertEqual(stopped.exception.code,0)
            self.assertEqual(os.environ['PIPELINE_PYTHON_BIN'],'WIN('+str(candidate)+')')
            self.assertEqual(os.environ['SASPY_CFGFILE'],'WIN(/cygdrive/c/sascfg.py)')
        self.assertEqual(run.call_count,1)
        self.assertEqual(run.call_args.args[0][-2:],['--code','proc print;run;'])
        execv.assert_not_called()

    @unittest.skipUnless(os.name=='nt','Mounted Windows client paths')
    def test_inline_mounted_client_file_is_resolved(self):
        with tempfile.TemporaryDirectory() as folder:
            file=Path(folder)/'data one.txt';file.write_text('data')
            spelling='/cygdrive/'+file.drive[0].lower()+file.as_posix()[2:]
            self.assertEqual(resolve_local(spelling,[]),file.resolve())
        self.assertIsNone(resolve_local('/home/remote/data.tsv',[]))

    @unittest.skipUnless(os.name=='nt' and os.environ.get('MCP4SAS_TEST_CYGWIN_PYTHON'),'Opt in with a Cygwin python.exe; no SAS submission is made')
    def test_actual_cygwin_to_native_handoff_without_sas(self):
        cygpython=Path(os.environ['MCP4SAS_TEST_CYGWIN_PYTHON'])
        cygpath=cygpython.with_name('cygpath.exe')
        native=os.environ.get('MCP4SAS_TEST_NATIVE_PYTHON',sys.executable)
        env=dict(os.environ,PIPELINE_PYTHON_BIN=native,OPEN_RESULT='0')
        env.pop('MCP4SAS_PYTHON_ENV_REEXEC',None)
        def posix(path):return subprocess.check_output([str(cygpath),'-u',str(path)],env=env,text=True).strip()
        with tempfile.TemporaryDirectory(prefix='handoff spaces ',dir=os.environ.get('MCP4SAS_TEST_OUTPUT_DIR')) as folder:
            directory=Path(folder)
            (directory/'sitecustomize.py').write_text('''import os
if os.environ.get("MCP4SAS_PYTHON_ENV_REEXEC")=="1":
 import json,sys
 import MCP4SAS_Use_Python.cli as cli
 def fake(args):
  print(json.dumps(dict(platform=sys.platform,code=args.code,file=args.file,output=args.output_prefix,cfg=args.saspy_cfgfile,remote=args.dir4listing,python=os.environ.get("PIPELINE_PYTHON_BIN"))))
  return 0
 cli.execute=fake
''',encoding='utf-8')
            env['PYTHONPATH']=posix(directory)+':'+posix(ROOT)
            config=directory/'test cfg.py';config.write_text('# Test file; no credentials or SAS calls.\n')
            env['SASPY_CFGFILE']=posix(config)
            output=directory/'output with spaces'
            code='%macroparas(macrorgx=GTEx,numlines2print=1000,print_outdsd=1);'
            common=[str(cygpython),posix(ROOT/'run_sas_codes_or_files_in_ODA.py')]
            requests=[['--code',code],['--file',posix(config),'--dir4listing','/home/remote']]
            for request in requests:
                result=subprocess.run(common+request+['--output-prefix',posix(output)],cwd=ROOT,env=env,capture_output=True,text=True,timeout=40)
                self.assertEqual(result.returncode,0,result.stderr)
                data=json.loads(result.stdout)
                self.assertEqual(data['platform'],'win32')
                self.assertEqual(Path(data['output']),output)
                self.assertEqual(Path(data['cfg']),config)
                self.assertEqual(Path(data['python']),Path(native))
                if '--code' in request:self.assertEqual(data['code'],code)
                else:
                    self.assertEqual(Path(data['file']),config)
                    self.assertEqual(data['remote'],'/home/remote')
                self.assertIn('restarting with the SASPy environment',result.stderr)


if __name__=='__main__':unittest.main(verbosity=2)
