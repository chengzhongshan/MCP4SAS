import contextlib
import io
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import time
import unittest
from unittest.mock import patch
from MCP4SAS_Use_Python import cli,diagnostics
from MCP4SAS_Use_Python.dependencies import Plan
from MCP4SAS_Use_Python import transport

class CopilotReviewTests(unittest.TestCase):
    def test_literal_windows_paths_are_preserved_and_decoding_is_explicit(self):
        text=r'filename input "C:\new\table.tsv"; %let pattern=\n;'
        with patch.object(cli,'Plan',wraps=Plan) as plan,contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(cli.main(['--code',text,'--dry-run']),0)
            self.assertEqual(plan.call_args.args[0],text)
        with patch.object(cli,'Plan',wraps=Plan) as plan,contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(cli.main(['--code',r'data x;\nrun;','--decode-code-escapes','--dry-run']),0)
            self.assertEqual(plan.call_args.args[0],'data x;\nrun;')

    def test_files_and_stdin_cannot_be_implicitly_decoded(self):
        text=r'%let path=C:\new\table.tsv;'
        with patch.object(cli.sys,'stdin',io.StringIO(text)),patch.object(cli,'Plan',wraps=Plan) as plan,contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(cli.main(['--code','-','--dry-run']),0)
            self.assertEqual(plan.call_args.args[0],text)
        with patch.object(cli.sys,'stdin',io.StringIO(text)),contextlib.redirect_stderr(io.StringIO()):
            self.assertEqual(cli.main(['--code','-','--decode-code-escapes','--dry-run']),2)

    def test_negative_timeout_and_empty_explicit_code_are_errors(self):
        for args in [['--code','','--dry-run'],['--code','run;','--run-timeout-seconds','-1'],
                     ['--code','run;','--run-timeout-grace-seconds','-1']]:
            with self.subTest(args=args),contextlib.redirect_stderr(io.StringIO()):
                self.assertEqual(cli.main(args),2)

    def test_explicit_invalid_interpreter_does_not_fall_back(self):
        args=cli.parser().parse_args(['--code','run;'])
        with patch.object(cli.importlib.util,'find_spec',return_value=object()),patch.object(cli,'find_saspy_interpreter',return_value=None),patch.dict(os.environ,{'PIPELINE_PYTHON_BIN':'missing-python','MCP4SAS_PYTHON_ENV_REEXEC':''}):
            with self.assertRaisesRegex(ValueError,'no different environment was substituted'):
                cli.ensure_saspy_environment(args)

    @unittest.skipUnless(importlib.util.find_spec('saspy') is not None,'Install runtime requirements for actual interpreter handoff')
    def test_actual_interpreter_handoff_preserves_quoted_arguments_without_sas(self):
        root=Path(__file__).resolve().parents[2]
        code=r'data x; text="alpha beta"; path="C:\new\table.tsv";run;'
        with tempfile.TemporaryDirectory(prefix='runner handoff ') as temp:
            site=Path(temp)/'sitecustomize.py'
            site.write_text('import os\nif os.environ.get("MCP4SAS_PYTHON_ENV_REEXEC")=="1":\n import json\n import MCP4SAS_Use_Python.cli as cli\n def fake(args):\n  print(json.dumps({"code":args.code,"output":args.output_prefix}))\n  return 0\n cli.execute=fake\n',encoding='utf-8')
            env=dict(os.environ,PIPELINE_PYTHON_BIN=sys.executable,PYTHONPATH=temp+os.pathsep+str(root),OPEN_RESULT='0')
            env.pop('MCP4SAS_PYTHON_ENV_REEXEC',None)
            output=str(Path(temp)/'output with spaces')
            result=subprocess.run([sys.executable,'-S',str(root/'run_sas_codes_or_files_in_ODA.py'),'--code',code,'--output-prefix',output],cwd=temp,env=env,capture_output=True,text=True,timeout=30)
            self.assertEqual(result.returncode,0,result.stderr)
            self.assertTrue(result.stdout.strip(),f'Child stdout missing; stderr={result.stderr!r}')
            self.assertEqual(json.loads(result.stdout),dict(code=code,output=output))
            self.assertIn('restarting with the SASPy environment',result.stderr)

    def test_browser_failure_is_advisory(self):
        with tempfile.TemporaryDirectory() as temp:
            path=Path(temp)/'output.html'
            path.write_text('<html>result</html>',encoding='utf-8')
            with patch.object(cli.os,'startfile',side_effect=OSError('unavailable'),create=True),patch.object(cli.subprocess,'run',side_effect=OSError('unavailable')),patch.object(cli.webbrowser,'open',side_effect=OSError('unavailable')),contextlib.redirect_stderr(io.StringIO()) as messages:
                self.assertFalse(cli.open_result_html(path))
                self.assertIn('Could not auto-open',messages.getvalue())

    def test_json_does_not_open_a_browser(self):
        class FakeRunner:
            def __init__(self,**kwargs): pass
            def __enter__(self): return self
            def __exit__(self,*args): pass
            def run(self,*args,**kwargs): return dict(log='NOTE: done',lst='<html>result</html>',diagnostics=diagnostics.classify(''))
        with tempfile.TemporaryDirectory() as temp,patch('MCP4SAS_Use_Python.runner.Runner',FakeRunner),patch.object(cli,'open_result_html') as browser,contextlib.redirect_stdout(io.StringIO()) as output:
            self.assertEqual(cli.main(['--code','run;','--json','--output-prefix',temp]),0)
            self.assertEqual(json.loads(output.getvalue())['exit_code'],0)
            browser.assert_not_called()

    def test_network_error_hints_exclude_source_and_output_text(self):
        error='ERROR: Windows error code: 67 in hx_disk_access'
        for text in ['12 '+error,'MPRINT(TEST): '+error,'NOTE: '+error,
                     '=== SAS Log ===\nNOTE: done\n=== Output ===\n'+error]:
            with self.subTest(text=text):
                self.assertEqual(diagnostics.classify(text)['exit_code'],0)
                self.assertEqual(diagnostics.summarize(text).get('infrastructure_count',0),0)

    def test_graceful_windows_shutdown_tracks_children_after_root_exits(self):
        for reuse in (False,True):
            alive={10:(1,0),20:(2,0)};calls=[]
            def run(args,**kwargs):
                calls.append(args)
                if '/F' not in args:
                    alive.pop(10,None)
                    if reuse: alive[20]=(3,0)
                else: alive.pop(int(args[2]),None)
            with self.subTest(reused_pid=reuse),patch.object(transport.os,'name','nt'),patch.object(transport,'windows_owned_tree',return_value=dict(alive)),patch.object(transport,'windows_identity',side_effect=lambda pid:alive.get(pid)),patch.object(transport.subprocess,'run',side_effect=run),patch.object(transport.time,'monotonic',side_effect=[0,1]):
                transport.stop_owned_pid(10,grace_seconds=.1)
            forced=[c for c in calls if '/F' in c]
            self.assertEqual(forced,[] if reuse else [['taskkill.exe','/PID','20','/T','/F']])

    @unittest.skipUnless(os.name=='nt','Windows Toolhelp process identity API')
    def test_real_windows_tree_identity_and_owned_child_shutdown(self):
        from MCP4SAS_Use_Python.windows_processes import identity,owned_tree
        self.assertEqual(owned_tree(os.getpid())[os.getpid()],identity(os.getpid()))
        script='import subprocess,sys,time; p=subprocess.Popen([sys.executable,"-c","import time;time.sleep(30)"]); print(p.pid,flush=True);time.sleep(30)'
        parent=subprocess.Popen([sys.executable,'-c',script],stdout=subprocess.PIPE,text=True,creationflags=subprocess.CREATE_NO_WINDOW)
        child=int(parent.stdout.readline())
        try:
            tree=owned_tree(parent.pid)
            self.assertIn(child,tree)
            transport.stop_owned_pid(parent.pid,grace_seconds=.1,process=parent)
            parent.wait(timeout=10)
            deadline=time.monotonic()+5
            while transport.pid_alive(child) and time.monotonic()<deadline: time.sleep(.05)
            self.assertFalse(transport.pid_alive(child))
        finally:
            if parent.poll() is None: transport.stop_owned_process(parent)
            if transport.pid_alive(child): transport.stop_owned_pid(child)
            parent.stdout.close()

if __name__=='__main__': unittest.main()
