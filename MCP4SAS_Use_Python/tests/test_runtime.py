import contextlib
import gzip
import hashlib
import io
import json
import os
from pathlib import Path
import socket
import subprocess
import sys
import tempfile
import threading
import time
import unittest
from unittest.mock import Mock,patch

from MCP4SAS_Use_Python import source_analysis as sa,diagnostics
from MCP4SAS_Use_Python.cli import ensure_saspy_environment,main,normalize_cli_code_text,parser
from MCP4SAS_Use_Python.dependencies import Plan,find_macro,rewrite_paths
from MCP4SAS_Use_Python.local_home import expand_code_paths
from MCP4SAS_Use_Python.remote_cleanup import build_code
from MCP4SAS_Use_Python.tempfiles import Scratch,inspect_owned,remove_owned
from MCP4SAS_Use_Python.transport import request
from MCP4SAS_Use_Python.utilities import subset_expression

ROOT=Path(__file__).resolve().parents[2]

class SourceTests(unittest.TestCase):
    def test_inline_records_are_inert_and_offsets_survive(self):
        code="data x; input a $; datalines4;\n%bad ' /*\n;;;;\nrun;\n%real;"
        self.assertEqual(sa.analyze_source(code)['findings'],[])
        self.assertNotIn('%bad',sa.macro_dependency_view(code))
        self.assertIn('%real',sa.macro_dependency_view(code))
        self.assertEqual(len(sa.mask_noncode(code)),len(code))
    def test_quoted_comment_markers_are_not_comments(self):
        self.assertEqual(sa.analyze_source("data _null_; x='/*'; y=\"*/\";run;")['findings'],[])
    def test_macro_quotes_and_unquote(self):
        self.assertNotIn('%dummy',sa.macro_dependency_view("%let x=%nrstr(%dummy(a%)));"))
        self.assertIn('%real',sa.macro_dependency_view('%unquote(%nrstr(%real));'))
        self.assertNotIn('%dummy',sa.macro_dependency_view('%unquote(%nrstr(%nrstr(%dummy)));'))
    def test_deferred_includes_and_source_order(self):
        code="%inc 'a.sas' 'b.sas' / source2; data _null_; call execute('%include ''c.sas'';'); x='%include ''inert.sas'';';run;%include 'd.sas';"
        self.assertEqual(sa.include_targets(code),['a.sas','b.sas','c.sas','d.sas'])
    def test_resolve_only_enables_macro_dependency(self):
        code="x=resolve('%real() %include ''not_executed.sas'';');"
        self.assertIn('%real',sa.macro_dependency_view(code))
        self.assertEqual(sa.include_targets(code),[])
    def test_quote_closure_and_prx(self):
        self.assertTrue(sa.analyze_source("x='missing;")['findings'])
        self.assertEqual(sa.analyze_source('%let y=%sysfunc(prxmatch(/abc.*/,x));')['findings'],[])
    def test_advisories_and_macro_labels(self):
        self.assertTrue(sa.open_code_macro_issues('%do i=1 %to 3;%end;'))
        self.assertEqual(sa.open_code_macro_issues('%macro x; %do i=1 %to 3;%end;%mend;'),[])
        self.assertEqual(len(sa.fileref_name_issues('filename toolongref "x";')),1)
        self.assertEqual(len(sa.format_name_issues('proc format; value age2 1=2;run;')),1)

class DependencyTests(unittest.TestCase):
    def test_unreachable_macro_dir_falls_back_to_process_working_directory(self):
        with tempfile.TemporaryDirectory() as temp:
            root=Path(temp).resolve()
            macro=root/'current_macro.sas'
            macro.write_text('%macro current_macro; %mend;')
            original=Path.cwd()
            os.chdir(root)
            try:
                plan=Plan('%current_macro();',macro_dir=root/'missing')
                self.assertEqual(plan.roots[-1],root)
                self.assertIn(macro.resolve(),plan.macros)
                self.assertIn('using the current working directory',plan.macro_dir_warning)
                self.assertIn('macro_dir_warning',plan.as_dict())
            finally:
                os.chdir(original)

    def test_transitive_macro_include_and_data_graph(self):
        with tempfile.TemporaryDirectory() as temp:
            root=Path(temp)
            (root/'A.sas').write_text('%macro a; %b; %mend;')
            (root/'b.sas').write_text('%macro b; %put ok; %mend;')
            (root/'include.sas').write_text('proc import datafile="table.tsv" out=x;run;')
            (root/'table.tsv').write_text('a\n1\n')
            plan=Plan('%include "include.sas"; %a;',source_file=root/'main.sas',macro_dir=root)
            self.assertEqual(set(plan.files),{'A.sas','b.sas','include.sas','table.tsv'})
            self.assertEqual([p.name for p in plan.macros],['b.sas','A.sas'])
            with Scratch() as scratch:
                code,uploads=plan.prepare(scratch,'/home/scientist')
                self.assertIn('%include "/home/scientist/A.sas";',code)
                include=next(Path(item['local_path']) for item in uploads if Path(item['local_path']).name=='include.sas')
                self.assertIn('"/home/scientist/table.tsv"',include.read_text())
            self.assertEqual((root/'include.sas').read_text(),'proc import datafile="table.tsv" out=x;run;')
    def test_duplicate_upload_basenames_fail(self):
        with tempfile.TemporaryDirectory() as temp:
            paths=[]
            for sub in ('a','b'):
                path=Path(temp)/sub/'x.tsv'
                path.parent.mkdir()
                path.write_text(sub)
                paths.append(str(path))
            with self.assertRaisesRegex(ValueError,'same remote basename'):
                Plan('',uploads=paths)
    def test_cycle_is_reported_without_connecting(self):
        with tempfile.TemporaryDirectory() as temp:
            root=Path(temp)
            (root/'a.sas').write_text('%include "b.sas";')
            (root/'b.sas').write_text('%include "a.sas";')
            with self.assertRaisesRegex(ValueError,'Cyclic'):
                Plan('%include "a.sas";',source_file=root/'main.sas')
    def test_builtin_and_inert_strings_do_not_upload(self):
        plan=Plan("%let x=%sysfunc(today());x='%not_a_call()'; /* %ignored */")
        self.assertEqual(plan.remote_macros,[])
    def test_local_home_preserves_comments_and_cards(self):
        code="/* '~' */\nlibname x '~';\ndata a;input x $;datalines;\n'~'\n;run;"
        output=expand_code_paths(code,"C:/reader's project")
        self.assertIn("libname x 'C:/reader''s project';",output)
        self.assertIn("/* '~' */",output)
        self.assertIn("\n'~'\n",output)

class DiagnosticsTests(unittest.TestCase):
    def test_runtime_only_severity_and_deduplication(self):
        text="=== Submission Preflight ===\nWARNING: ignored\n=== SAS Log ===\n12 put 'WARNING: ignored';\nWARNING: real\nWARNING: real\nNOTE: Division by zero\nid=1 _ERROR_=1\n=== Output ===\nWARNING: ignored"
        result=diagnostics.summarize(text)
        self.assertEqual(result['warning_count'],1)
        self.assertEqual(result['data_quality_count'],2)
        self.assertEqual(diagnostics.classify('WARNING: real')['exit_code'],0)
        self.assertEqual(diagnostics.classify('ERROR: failed')['exit_code'],1)
    def test_infrastructure_errors_are_not_retried(self):
        self.assertEqual(diagnostics.classify('ERROR: Insufficient space in file WORK.X.DATA.\n')['exit_code'],73)
        self.assertEqual(diagnostics.classify('No SAS process attached')['exit_code'],74)
        self.assertFalse(diagnostics.classify('No SAS process attached')['retryable'])
    def test_windows_network_path_failure_has_actionable_diagnostic(self):
        text='=== SAS Log ===\nERROR:  Windows error code: 67 in hx_disk_access for \\\\\\\\server\\\\share, The network name cannot be found.\n=== Output ==='
        result=diagnostics.classify(text)
        self.assertEqual(result['failure_class'],'sas_windows_network_path_unavailable')
        self.assertFalse(result['retryable'])
        self.assertEqual(result['infrastructure_count'],1)
        self.assertIn('reachable from the SAS host',diagnostics.format_summary(result))
    def test_macro_hint(self):
        result=diagnostics.summarize('WARNING: Apparent invocation of macro HELLO not resolved.')
        self.assertEqual(result['macro_diagnostics'][0]['kind'],'unresolved_macro_invocation')

class UtilityTests(unittest.TestCase):
    def test_owned_scratch_cleanup_protects_other_paths(self):
        with tempfile.TemporaryDirectory() as temp:
            scratch=Scratch(temp)
            self.assertTrue(inspect_owned(scratch.path,temp))
            (scratch.path/'user.sas').write_text('source')
            remove_owned(scratch.path,temp)
            self.assertFalse(scratch.path.exists())
            with self.assertRaises(ValueError):
                remove_owned(temp,Path(temp).parent)
    def test_subset_plain_gzip_and_failures_are_atomic(self):
        with tempfile.TemporaryDirectory() as temp:
            root=Path(temp)
            content=b'gene\tLung\tBrain\nENSG|CD55\t1\t2\nOTHER\t3\t4\n'
            for suffix in ('.tsv','.tsv.gz'):
                file=root/('source'+suffix)
                file.write_bytes(gzip.compress(content) if suffix.endswith('.gz') else content)
                before=hashlib.sha256(file.read_bytes()).hexdigest()
                output=root/('result'+suffix+'.tsv')
                result=subset_expression(file,'CD55',output)
                self.assertEqual(result['kept'],1)
                self.assertEqual(output.read_bytes(),content.splitlines(keepends=True)[0]+content.splitlines(keepends=True)[1])
                self.assertEqual(hashlib.sha256(file.read_bytes()).hexdigest(),before)
                with self.assertRaises(FileExistsError):
                    subset_expression(file,'CD55',output)
            with self.assertRaisesRegex(ValueError,'Missing requested'):
                subset_expression(root/'source.tsv','UNKNOWN',root/'absent.tsv')
            self.assertFalse((root/'absent.tsv').exists())
            self.assertEqual(list(root.glob('.gtex-subset-*')),[])
    def test_remote_cleanup_guards_and_preview(self):
        for parent in ('/','~/../','/tmp/../home','~/a&b'):
            with self.assertRaises(ValueError):
                build_code(parent=parent,patterns=['.*'])
        code=build_code(names=['owned'],dry_run=True)
        self.assertNotIn('%Del_Dir_Recursive(',code)
        self.assertIn('dry_run=1',code)
    def test_help_dry_run_and_alias_need_no_saspy(self):
        for name in ('run_sas_codes_or_files_in_ODA.py','run_sas_codes_or_script_in_ODA.py'):
            help_result=subprocess.run([sys.executable,'-S',str(ROOT/name)],capture_output=True,text=True,cwd=ROOT)
            self.assertEqual(help_result.returncode,0,help_result.stderr)
            self.assertIn('usage:',help_result.stdout.lower())
            self.assertIn('--file',help_result.stdout)
            result=subprocess.run([sys.executable,'-S',str(ROOT/name),'--code','proc print;run;','--dry-run'],capture_output=True,text=True,cwd=ROOT)
            self.assertEqual(result.returncode,0,result.stderr)
            self.assertTrue(json.loads(result.stdout)['dry_run'])
    def test_cli_options_match_perl_compatibility_forms(self):
        args=parser().parse_args([
            '--cleanup-empty-output-dir=0','--download-file','~/remote.txt',
            '--download-local-path','local.txt','--no-prompt-sas-oda-auth',
            '--no-skip-sas-oda-auth-bootstrap','--no-check-sas-oda-login-only',
            '--no-delete-directory-dry-run','--run-timeout-grace-seconds','4',
        ])
        self.assertEqual(args.cleanup_empty_output_dir,'0')
        self.assertEqual(args.download_file,['~/remote.txt'])
        self.assertEqual(args.download_local_path,['local.txt'])
        self.assertFalse(args.prompt_sas_oda_auth)
        self.assertFalse(args.skip_sas_oda_auth_bootstrap)
        self.assertFalse(args.check_sas_oda_login_only)
        self.assertFalse(args.delete_directory_dry_run)
        self.assertEqual(args.run_timeout_grace_seconds,4)
        help_text=parser().format_help()
        for option in ('--macro-dir','--upload-file','--download-file','--delete-file-rgx','--file-info','--monitor-status-file','--run-timeout-grace-seconds'):
            self.assertIn(option,help_text)
    def test_cli_expands_escaped_code_whitespace_like_perl(self):
        self.assertEqual(normalize_cli_code_text(r'data x;\r\nrun;\t'), 'data x;\nrun;\t')
    def test_cli_restarts_with_project_python_when_saspy_is_missing(self):
        args=parser().parse_args(['--code','proc print;run;'])
        candidate=Path('project-env/python')
        with patch('MCP4SAS_Use_Python.cli.importlib.util.find_spec',return_value=None),patch('MCP4SAS_Use_Python.cli.find_saspy_interpreter',return_value=(candidate,{'prefix':'project-env'})),patch('MCP4SAS_Use_Python.cli.os.execv') as execv,patch('MCP4SAS_Use_Python.cli.subprocess.run',return_value=Mock(returncode=0)) as restart,patch.dict(os.environ,{'MCP4SAS_PYTHON_ENV_REEXEC':''}),contextlib.redirect_stderr(io.StringIO()):
            if os.name=='nt':
                with self.assertRaises(SystemExit) as stopped: ensure_saspy_environment(args)
                self.assertEqual(stopped.exception.code,0)
            else: ensure_saspy_environment(args)
        command=[str(candidate),str(ROOT/'run_sas_codes_or_files_in_ODA.py'),*sys.argv[1:]]
        if os.name=='nt':
            self.assertEqual(restart.call_args.args[0],command)
            execv.assert_not_called()
        else: execv.assert_called_once_with(str(candidate),command)
    def test_cli_dry_run_does_not_require_saspy_environment(self):
        args=parser().parse_args(['--code','proc print;run;','--dry-run'])
        with patch('MCP4SAS_Use_Python.cli.importlib.util.find_spec') as find_spec,patch('MCP4SAS_Use_Python.cli.find_saspy_interpreter') as find_python:
            ensure_saspy_environment(args)
        find_spec.assert_not_called()
        find_python.assert_not_called()
    def test_cli_passes_timeout_grace_to_backend(self):
        seen={}
        class FakeRunner:
            def __init__(self,**kwargs): seen.update(kwargs)
            def __enter__(self): return self
            def __exit__(self,*args): pass
            def run(self,*args,**kwargs):
                return dict(log='NOTE: SAS completed.',lst='',diagnostics=diagnostics.classify('NOTE: SAS completed.'))
        with tempfile.TemporaryDirectory() as temp,patch('MCP4SAS_Use_Python.runner.Runner',FakeRunner),patch.dict(os.environ,{'OPEN_RESULT':'0'}),contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(main(['--code','proc print;run;','--run-timeout-grace-seconds','7','--output-prefix',str(Path(temp)/'result')]),0)
        self.assertEqual(seen['timeout_grace_seconds'],7)
    def test_cli_saves_html_without_dumping_markup_to_terminal(self):
        html='<html><body><table><tr><td>result</td></tr></table></body></html>'
        class FakeRunner:
            def __init__(self,**kwargs): pass
            def __enter__(self): return self
            def __exit__(self,*args): pass
            def run(self,*args,**kwargs):
                return dict(log='NOTE: SAS completed.',lst=html,diagnostics=diagnostics.classify('NOTE: SAS completed.'))
        with tempfile.TemporaryDirectory() as temp,patch('MCP4SAS_Use_Python.runner.Runner',FakeRunner),patch('MCP4SAS_Use_Python.cli.open_result_html') as open_html,patch.dict(os.environ,{'OPEN_RESULT':'0'}),contextlib.redirect_stdout(io.StringIO()) as stdout:
            output=(Path(temp)/'result').resolve()
            self.assertEqual(main(['--code','proc print;run;','--output-prefix',str(output)]),0)
            terminal=stdout.getvalue()
            self.assertNotIn('<html>',terminal)
            self.assertIn('HTML output saved to: '+str(output/'output.html'),terminal)
            self.assertEqual((output/'output.html').read_text(encoding='utf-8'),html)
            open_html.assert_not_called()
    def test_cli_opens_saved_html_by_default(self):
        html='<html><body>result</body></html>'
        class FakeRunner:
            def __init__(self,**kwargs): pass
            def __enter__(self): return self
            def __exit__(self,*args): pass
            def run(self,*args,**kwargs):
                return dict(log='NOTE: SAS completed.',lst=html,diagnostics=diagnostics.classify('NOTE: SAS completed.'))
        with tempfile.TemporaryDirectory() as temp,patch('MCP4SAS_Use_Python.runner.Runner',FakeRunner),patch('MCP4SAS_Use_Python.cli.open_result_html') as open_html,patch.dict(os.environ,{}),contextlib.redirect_stdout(io.StringIO()):
            os.environ.pop('OPEN_RESULT',None)
            output=(Path(temp)/'result').resolve()
            self.assertEqual(main(['--code','proc print;run;','--output-prefix',str(output)]),0)
            open_html.assert_called_once_with(output/'output.html')
    def test_cygwin_html_open_uses_cygstart(self):
        from MCP4SAS_Use_Python.cli import open_result_html
        with tempfile.TemporaryDirectory() as temp:
            path=Path(temp)/'output.html'
            path.write_text('<html>result</html>',encoding='utf-8')
            with patch('MCP4SAS_Use_Python.cli.sys.platform','cygwin'),patch('MCP4SAS_Use_Python.cli.shutil.which',return_value='/usr/bin/cygstart'),patch('MCP4SAS_Use_Python.cli.subprocess.run',return_value=subprocess.CompletedProcess([],0,'','')) as run:
                self.assertTrue(open_result_html(path))
            self.assertEqual(run.call_args.args[0],['/usr/bin/cygstart',str(path.resolve())])
            self.assertEqual(run.call_args.kwargs['timeout'],15)
    def test_bad_input_never_constructs_backend(self):
        with patch('MCP4SAS_Use_Python.runner.Backend',side_effect=AssertionError('must not connect')):
            with contextlib.redirect_stderr(io.StringIO()):
                self.assertEqual(main(['--file','__missing_file__.sas']),2)
    def test_file_regex_never_deletes_unix_or_windows_directory_entries(self):
        deleted=[]
        class FakeRunner:
            def __init__(self,**kwargs): pass
            def __enter__(self): return self
            def __exit__(self,*args): pass
            def dirlist(self,path): return ['Macros/','Other\\','one.txt','two.csv']
            def delete(self,path,parent):
                deleted.append(path)
                return {'status':'ok'}
        with tempfile.TemporaryDirectory() as temp,patch('MCP4SAS_Use_Python.runner.Runner',FakeRunner),contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(main(['--delete-file-rgx','.*','--output-prefix',str(Path(temp)/'result')]),0)
        self.assertEqual(deleted,['one.txt','two.csv'])

class TransportTests(unittest.TestCase):
    def test_fragmented_frames_and_progress(self):
        listener=socket.socket()
        listener.bind(('127.0.0.1',0))
        listener.listen()
        port=listener.getsockname()[1]
        def serve():
            with listener,listener.accept()[0] as client:
                from MCP4SAS_Use_Python.transport import recv_exact
                size=int.from_bytes(recv_exact(client,8),'big')
                request_data=json.loads(recv_exact(client,size))
                self.assertEqual(request_data['_token'],'secret')
                for value in [dict(status='progress',kind='test'),dict(status='ok',log='done')]:
                    data=json.dumps(value).encode()
                    frame=len(data).to_bytes(8,'big')+data
                    for i in range(0,len(frame),3):
                        client.sendall(frame[i:i+3])
        thread=threading.Thread(target=serve)
        thread.start()
        progress=[]
        result=request(port,'secret',dict(cmd='test'),timeout=5,progress=progress.append)
        thread.join()
        self.assertEqual(result['log'],'done')
        self.assertEqual(len(progress),1)
    def test_timeout_uses_configured_grace_for_backend_shutdown(self):
        from MCP4SAS_Use_Python.transport import Backend
        backend=Backend.__new__(Backend)
        backend.timeout=1
        backend.timeout_grace_seconds=7
        backend.session_id='test'
        backend.local_home=None
        backend.port=1234
        backend.token='token'
        backend.launcher_pid=42
        backend.pid=42
        backend.process=None
        backend.record=Mock()
        with patch('MCP4SAS_Use_Python.transport.request',side_effect=TimeoutError('timed out')),patch('MCP4SAS_Use_Python.transport.stop_owned_pid') as stop:
            with self.assertRaises(TimeoutError):
                backend.call('submit')
        stop.assert_called_once_with(42,7,process=None)
        backend.record.unlink.assert_called_once_with(missing_ok=True)

if __name__=='__main__':
    unittest.main()
