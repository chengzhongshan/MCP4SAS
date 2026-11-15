"""Python SAS runner. Help, dry-run and log classification need no SASPy."""
import argparse
from datetime import datetime,timezone
import getpass
import importlib.util
import json
import os
from pathlib import Path
import re
import secrets
import shutil
import sys
import subprocess
import time
import webbrowser
from . import diagnostics,source_analysis
from .dependencies import Plan,read_source
from .java_help import instructions

def atomic_json(path,value):
    path=Path(path)
    path.parent.mkdir(parents=True,exist_ok=True)
    temp=path.with_name(path.name+'.tmp-'+secrets.token_hex(4))
    try:
        with temp.open('x',encoding='utf-8') as handle:
            json.dump(value,handle,ensure_ascii=False,indent=2)
        os.replace(temp,path)
    finally:
        temp.unlink(missing_ok=True)

def open_result_html(path):
    detail=''
    if sys.platform.startswith('cygwin'):
        cygstart=shutil.which('cygstart')
        if cygstart:
            try:
                subprocess.Popen([cygstart,str(path)],stdin=subprocess.DEVNULL,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL,start_new_session=True)
                return True
            except OSError as exc:
                detail=str(exc)
    if os.name=='nt':
        startfile=getattr(os,'startfile',None)
        if startfile:
            try:
                startfile(str(path))
                return True
            except OSError as exc:
                detail=str(exc)
    try:
        if webbrowser.open(path.as_uri()):
            return True
    except (OSError,webbrowser.Error) as exc:
        detail=str(exc)
    warning=f'WARNING: Could not auto-open {path} with the system default browser. Set OPEN_RESULT=0 to suppress this attempt.'
    if detail:
        warning+=' '+detail
    print(warning,file=sys.stderr)
    return False

def normalize_cli_code_text(text):
    return (text.replace('\\r\\n','\n').replace('\\n','\n')
            .replace('\\r','\r').replace('\\t','\t'))

def _python_candidates():
    configured=os.environ.get('PIPELINE_PYTHON_BIN')
    if configured:
        candidate=Path(configured).expanduser()
        if not candidate.is_file():
            resolved=shutil.which(configured)
            if resolved:
                candidate=Path(resolved)
        if candidate.is_file():
            yield candidate
        # An explicit interpreter is a request, not permission to silently
        # substitute a different environment when that request is invalid.
        return
    project_root=Path(__file__).resolve().parents[1]
    roots=(project_root,project_root.parent)
    seen=set()
    for root in roots:
        environments=(root/'.venv-pipeline',root/'MCP4SAS_Use_Python'/'.venv')
        for environment in environments:
            record=environment/'.python-bin'
            if record.is_file():
                try:
                    recorded=record.read_text(encoding='utf-8').strip()
                except OSError:
                    recorded=''
                if recorded:
                    candidate=Path(recorded).expanduser()
                    if candidate.is_file():
                        key=os.path.normcase(str(candidate))
                        if key not in seen:
                            seen.add(key)
                            yield candidate
            for relative in ('bin/python','bin/python3','Scripts/python.exe','Scripts/python'):
                candidate=environment/relative
                if candidate.is_file():
                    key=os.path.normcase(str(candidate))
                    if key not in seen:
                        seen.add(key)
                        yield candidate

def _probe_python(candidate):
    source='import importlib.util,json,sys; print(json.dumps({"version":list(sys.version_info[:2]),"platform":sys.platform,"prefix":sys.prefix,"saspy":importlib.util.find_spec("saspy") is not None}))'
    try:
        result=subprocess.run([str(candidate),'-c',source],capture_output=True,text=True,timeout=10,check=False)
    except (OSError,subprocess.TimeoutExpired):
        return None
    if result.returncode:
        return None
    try:
        info=json.loads(result.stdout.strip().splitlines()[-1])
    except (IndexError,ValueError):
        return None
    if info.get('version',[0,0]) < [3,10] or info.get('platform')!=sys.platform or not info.get('saspy'):
        return None
    return info

def find_saspy_interpreter():
    for candidate in _python_candidates():
        info=_probe_python(candidate)
        if info:
            return candidate,info
    return None

def _requires_saspy(args):
    if args.dry_run or args.classify_sas_log or args.monitor_status_file:
        return False
    return any((args.code,args.file,args.upload_file,args.download_file,args.delete_file,
                args.delete_file_rgx,args.delete_directory_rgx,args.delete_directory_dry_run,
                args.dir4listing,args.file_info,args.check_sas_oda_login_only,
                args.kill_saspy_sessions))

def ensure_saspy_environment(args):
    if not _requires_saspy(args):
        return
    try:
        current_has_saspy=importlib.util.find_spec('saspy') is not None
    except (ImportError,ValueError):
        current_has_saspy=False
    current_is_compatible=sys.version_info >= (3,10) and current_has_saspy
    configured=bool(os.environ.get('PIPELINE_PYTHON_BIN'))
    if current_is_compatible and not configured:
        os.environ.pop('MCP4SAS_PYTHON_ENV_REEXEC',None)
        return
    if os.environ.get('MCP4SAS_PYTHON_ENV_REEXEC'):
        if current_is_compatible:
            os.environ.pop('MCP4SAS_PYTHON_ENV_REEXEC',None)
            return
        raise ValueError(f'SASPy is still unavailable after switching Python interpreters ({sys.executable})')
    selected=find_saspy_interpreter()
    if selected:
        candidate,info=selected
        if current_is_compatible and Path(info['prefix']).resolve()==Path(sys.prefix).resolve():
            return
        os.environ['MCP4SAS_PYTHON_ENV_REEXEC']='1'
        print(f'MCP4SAS Python: restarting with the SASPy environment {candidate}',file=sys.stderr,flush=True)
        launcher=Path(__file__).resolve().parents[1]/'run_sas_codes_or_files_in_ODA.py'
        command=[str(candidate),str(launcher),*sys.argv[1:]]
        if os.name=='nt':
            # Windows CRT execv does not quote space-containing arguments for
            # the new process. subprocess supplies the required quoting once.
            flags=0 if sys.stdin.isatty() else subprocess.CREATE_NO_WINDOW
            raise SystemExit(subprocess.run(command,check=False,creationflags=flags,
                stdin=sys.stdin,stdout=sys.stdout,stderr=sys.stderr).returncode)
        os.execv(str(candidate),command)
        return
    if configured:
        raise ValueError('PIPELINE_PYTHON_BIN is not a compatible Python 3.10+ interpreter with SASPy for this platform. Correct or clear that setting; no different environment was substituted.')
    if current_is_compatible:
        return
    raise ValueError(
        f'SASPy is not available in {sys.executable}, and no compatible project Python environment was found. '
        'Set PIPELINE_PYTHON_BIN to a Python 3.10+ interpreter with SASPy, or install the Python environment '
        'described in MCP4SAS_Use_Python/README.md.'
    )

def parser():
    p=argparse.ArgumentParser(
        description='Run SAS through a native Python MCP4SAS runtime; no Perl required.',
        allow_abbrev=False,
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
        epilog='Environment: SAS_ODA_RUN_TIMEOUT_SECONDS, SAS_ODA_RUN_TIMEOUT_GRACE_SECONDS, '
               'SASPY_CFGNAME, SASPY_CFGFILE, OPEN_RESULT. Use --prompt-sas-oda-auth '
               'instead of passing a password on the command line.',
    )
    group=p.add_mutually_exclusive_group()
    group.add_argument('--code','--codes','-c',help="SAS code to execute; use '-' for stdin. Backslashes are preserved unless --decode-code-escapes is explicitly selected.")
    p.add_argument('--decode-code-escapes',action='store_true',help='Opt-in Perl-style expansion of literal \\n, \\r\\n, \\r and \\t in direct --code text only; do not use for Windows paths or regex literals.')
    group.add_argument('--file','-file','-f',help='SAS program file to execute.')
    p.add_argument('--macro-dir','-m',help='Local directory containing SAS macros; an unreachable directory falls back to the current working directory.')
    p.add_argument('--output-prefix','-p',help='Output directory/prefix for run artifacts.')
    p.add_argument('--session-id','-s',help='Reuse a persistent SAS session with this ID.')
    p.add_argument('--persistent',action=argparse.BooleanOptionalAction,default=None,help='Keep a SAS session alive; --session-id is required to reuse it.')
    p.add_argument('--skip-upload-if-same',action=argparse.BooleanOptionalAction,default=True,help='Reuse an unchanged remote upload with the same basename.')
    p.add_argument('--archive-transfers',action=argparse.BooleanOptionalAction,default=True,help='Bundle multiple file transfers into a ZIP.')
    p.add_argument('--cleanup-empty-output-dir',nargs='?',const='1',choices=('0','1'),default='1',metavar='{0,1}',help='Remove a newly created output directory if it is left empty; accepts legacy 0/1 forms.')
    p.add_argument('--no-cleanup-empty-output-dir',dest='cleanup_empty_output_dir',action='store_const',const='0',help='Keep a newly created output directory even if it is empty.')
    p.add_argument('--keep-intermediate-files',action=argparse.BooleanOptionalAction,default=False,help='Retain the owned scratch directory for debugging.')
    for name,alias in [('upload-file','-u'),('download-file','-d'),('delete-file','-k'),('dir4listing','-l')]:
        help_text={
            'upload-file':'Upload a local file to SAS ODA; repeat for multiple files.',
            'download-file':'Download a remote SAS ODA file; repeat for multiple files.',
            'delete-file':'Delete a remote file; repeat for multiple files.',
            'dir4listing':'List files in a remote directory.',
        }[name]
        p.add_argument('--'+name,alias,action='append' if name!='dir4listing' else 'store',default=[] if name!='dir4listing' else None,help=help_text)
    p.add_argument('--download-local-path',action='append',default=[],help='Local destination paired by position with each --download-file.')
    p.add_argument('--delete-file-rgx',action='append',default=[],help='Delete remote files matching this regular expression; repeatable.')
    p.add_argument('--delete-directory-rgx',action='append',default=[],help='Recursively delete matching immediate-child directories; repeatable.')
    p.add_argument('--delete-directory-dry-run',action=argparse.BooleanOptionalAction,default=False,help='Preview directory matches without deleting them.')
    p.add_argument('--delete-dir',default='~',help='Remote parent directory for delete regex operations.')
    p.add_argument('--file-info',action='append',default=[],help='Return remote file metadata; repeatable.')
    p.add_argument('--saspy-cfgname',default=os.environ.get('SASPY_CFGNAME') or os.environ.get('SASPY_CONFIG_NAME') or 'oda',help='SASPy target/configuration name.')
    generated_config=Path(__file__).parent/'.saspy-config/sascfg_personal.py'
    p.add_argument('--saspy-cfgfile',default=os.environ.get('SASPY_CFGFILE') or (str(generated_config) if generated_config.is_file() else None),help='Path to a SASPy configuration file.')
    p.add_argument('--dir4local_sas_home',help='Local SAS HOME used for local SAS file actions and quoted paths.')
    p.add_argument('--classify-sas-log',help='Classify an existing SAS log without connecting.')
    p.add_argument('--run-timeout-seconds',type=int,default=int(os.environ.get('SAS_ODA_RUN_TIMEOUT_SECONDS','3600')),help='Timeout for each SASPy backend operation; 0 disables it. Startup, multiple transfers and shutdown can add elapsed time.')
    p.add_argument('--run-timeout-grace-seconds',type=int,default=int(os.environ.get('SAS_ODA_RUN_TIMEOUT_GRACE_SECONDS','15')),help='Wait after requesting backend termination before forcing it.')
    p.add_argument('--no-run-timeout',action='store_true',help='Disable the overall run timeout.')
    p.add_argument('--no-html-info','--no-html_info',action='store_true',help='Do not save the returned HTML file.')
    p.add_argument('--dry-run',action='store_true',help='Print dependency/preflight information without connecting to SAS.')
    p.add_argument('--json',action='store_true',help='Print machine-readable outcome rather than a text report.')
    p.add_argument('--monitor-status-file',help='Follow a live run-status JSON file and exit when complete.')
    p.add_argument('--monitor-interval-seconds',type=int,default=5,help='Polling interval for --monitor-status-file.')
    p.add_argument('--check-sas-oda-login-only','--check-saspy-connection-only',action=argparse.BooleanOptionalAction,default=False,help='Validate the selected SASPy connection and exit.')
    p.add_argument('--prompt-sas-oda-auth',action=argparse.BooleanOptionalAction,default=False,help='Prompt privately for SAS ODA credentials and save them in the local auth file.')
    p.add_argument('--sas-oda-account',help='SAS ODA account/email for credential setup.')
    p.add_argument('--sas-oda-password',help='SAS ODA password (not recommended; use the private prompt instead).')
    p.add_argument('--skip-sas-oda-auth-bootstrap',action=argparse.BooleanOptionalAction,default=False,help='Skip interactive or supplied-credential setup.')
    p.add_argument('--kill-saspy-sessions','--kill-sas-oda-sessions','--kill-saspy-session-server',action=argparse.BooleanOptionalAction,default=False,help='Close only the Python runtime/session, not unrelated Perl or Java processes.')
    return p

def configure_credentials(args):
    if not (args.prompt_sas_oda_auth or args.sas_oda_account or args.sas_oda_password):
        return
    if args.saspy_cfgname!='oda':
        raise ValueError('ODA credentials apply only to the oda profile')
    account=args.sas_oda_account or input('SAS ODA account/email: ')
    password=args.sas_oda_password or getpass.getpass('SAS ODA password (private terminal only): ')
    if not account or not password or re.search(r'\s',account+password):
        raise ValueError('The authinfo format requires nonempty account/password without whitespace; use a private SASPy profile for other credentials')
    home=Path(os.environ.get('HOME') or Path.home())
    path=home/('_authinfo' if os.name=='nt' else '.authinfo')
    existing=path.read_text(encoding='utf-8') if path.exists() else ''
    key=os.environ.get('SASPY_ODA_AUTHKEY','oda')
    lines=[line for line in existing.splitlines() if not re.match(r'^\s*'+re.escape(key)+r'\s+user\s+',line,re.I)]
    temp=path.with_name(path.name+'.mcp4sas-'+secrets.token_hex(6))
    fd=os.open(temp,os.O_CREAT|os.O_EXCL|os.O_WRONLY,0o600)
    try:
        with os.fdopen(fd,'w',encoding='utf-8',newline='\n') as handle:
            handle.write('\n'.join(lines+[f'{key} user {account} password {password}'])+'\n')
        os.replace(temp,path)
    finally:
        temp.unlink(missing_ok=True)
    print(f'Private ODA account entry saved to {path}; credentials were not printed.',file=sys.stderr)

def execute(args):
    if args.classify_sas_log:
        result=diagnostics.classify(read_source(args.classify_sas_log))
        print(json.dumps(result,indent=2))
        return result['exit_code']
    if args.monitor_status_file:
        while True:
            status=json.loads(Path(args.monitor_status_file).read_text(encoding='utf-8'))
            print(json.dumps(status),flush=True)
            if status.get('complete'):
                return status.get('exit_code',1)
            time.sleep(max(1,args.monitor_interval_seconds))
    if args.run_timeout_seconds<0 or args.run_timeout_grace_seconds<0:
        raise ValueError('Timeout and timeout grace must be nonnegative; use --no-run-timeout explicitly to disable the timeout')
    args.cleanup_empty_output_dir=args.cleanup_empty_output_dir=='1'
    if args.session_id and not re.fullmatch(r'[A-Za-z0-9_-]+',args.session_id):
        raise ValueError('Use letters, numbers, underscores or hyphens in a session ID')
    persistent=args.persistent if args.persistent is not None else bool(args.session_id)
    session_id=(args.session_id or 'default_session') if persistent else None
    if args.decode_code_escapes and (args.file or args.code in (None,'-')):
        raise ValueError('--decode-code-escapes requires direct --code text; files and stdin are preserved')
    code=read_source(args.file) if args.file else sys.stdin.read() if args.code=='-' else args.code or ''
    if args.decode_code_escapes:
        code=normalize_cli_code_text(code)
    if args.delete_directory_rgx:
        if code or args.file:
            raise ValueError('Directory cleanup must run separately from --code or --file')
        from .remote_cleanup import build_code
        code=build_code(parent=args.delete_dir,patterns=args.delete_directory_rgx,dry_run=args.delete_directory_dry_run)
    elif args.delete_directory_dry_run:
        raise ValueError('--delete-directory-dry-run requires --delete-directory-rgx')
    if len(args.download_local_path) not in (0,len(args.download_file)):
        raise ValueError('Provide zero or one --download-local-path for every --download-file')
    if not any((code,args.upload_file,args.download_file,args.delete_file,args.delete_file_rgx,args.dir4listing,args.file_info,args.check_sas_oda_login_only,args.kill_saspy_sessions)):
        raise ValueError('Supply --code, --file, a file operation, or --check-saspy-connection-only')
    plan=Plan(code,args.file,args.macro_dir,args.upload_file)
    analysis=plan.analysis
    advisories=source_analysis.open_code_macro_issues(code,analysis['masked'])+source_analysis.format_name_issues(code,analysis['masked'])+source_analysis.fileref_name_issues(code,analysis['masked'])
    if args.dry_run:
        print(json.dumps(dict(dry_run=True,persistent=persistent,session_id=session_id,dependencies=plan.as_dict(),preflight=analysis['findings'],advisories=advisories),indent=2))
        return 0
    # Only lexical failures block submission; advisory heuristics preserve SAS as authority.
    if analysis['findings']:
        raise ValueError('SAS source preflight failed: '+json.dumps(analysis['findings']))
    if not args.skip_sas_oda_auth_bootstrap:
        configure_credentials(args)
    from .runner import Runner
    timeout=0 if args.no_run_timeout else args.run_timeout_seconds
    local_home=None
    if args.dir4local_sas_home:
        local_home=str(Path(args.dir4local_sas_home).resolve())
        Path(local_home).mkdir(parents=True,exist_ok=True)
    outdir=Path(args.output_prefix or 'SAS_Output_Python_'+datetime.now().strftime('%Y%m%d_%H%M%S')+'_'+secrets.token_hex(4)).resolve()
    output_dir_existed=outdir.exists()
    outdir.mkdir(parents=True,exist_ok=True)
    status_path=outdir/'output.html.run.status.json'
    started=datetime.now(timezone.utc).isoformat()
    status=dict(state='running',complete=False,success=False,started_at=started,pid=os.getpid(),runtime='python',session_id=session_id)
    try:
        atomic_json(status_path,status)
    except BaseException:
        if args.cleanup_empty_output_dir and not output_dir_existed:
            try:
                outdir.rmdir()
            except OSError:
                pass
        raise
    result=dict(log='',lst='',diagnostics=diagnostics.classify(''),advisories=advisories)
    code_exit=0
    try:
        with Runner(session_id=session_id,timeout=timeout,timeout_grace_seconds=args.run_timeout_grace_seconds,cfgname=args.saspy_cfgname,cfgfile=args.saspy_cfgfile,local_home=local_home,archive_transfers=args.archive_transfers,skip_upload_if_same=args.skip_upload_if_same) as runner:
            if args.kill_saspy_sessions:
                runner.close(force=True)
                result['log']='NOTE: Selected Python SAS session closed. Other runtimes were not stopped.\n'
            elif args.check_sas_oda_login_only:
                result.update(runner.run('proc setinit; run;'))
            elif code:
                result.update(runner.run(code,args.file,args.macro_dir,args.upload_file,args.keep_intermediate_files,prepared_plan=plan,submitted_path=outdir/'submitted.sas'))
            elif args.upload_file:
                result['transfers']=runner.transfer(uploads=[dict(local_path=str(Path(p).resolve()),skip_if_same=args.skip_upload_if_same) for p in args.upload_file])
            if not args.kill_saspy_sessions:
                if args.download_file:
                    result['downloads']=runner.transfer(downloads=[dict(remote_path=remote,local_path=str(Path(args.download_local_path[i] if args.download_local_path else Path(remote).name).resolve())) for i,remote in enumerate(args.download_file)])
                if args.dir4listing:
                    result['files']=runner.dirlist(args.dir4listing)
                if args.file_info:
                    result['file_info']={path:runner.fileinfo(path) for path in args.file_info}
                result['deleted']=[runner.delete(path,args.delete_dir) for path in args.delete_file]
                for pattern in args.delete_file_rgx:
                    regex=re.compile(pattern)
                    entries=runner.dirlist(args.delete_dir)
                    for entry in entries:
                        name=entry if isinstance(entry,str) else entry[0]
                        # Directories require the separately guarded cleanup operation.
                        if not name.endswith(('/','\\')) and regex.search(name):
                            result['deleted'].append(runner.delete(name,args.delete_dir))
            code_exit=result['diagnostics']['exit_code']
    except OSError as exc:
        # OSError includes transport/network errors; never replay user submissions.
        code_exit=124 if isinstance(exc,TimeoutError) else 1
        result['error']=str(exc)+instructions(str(exc))
    except Exception as exc:
        code_exit=result.get('diagnostics',{}).get('exit_code') or 1
        result['error']=str(exc)+instructions(str(exc))
    html_path=None
    output_summary='No HTML output was returned.'
    if result.get('lst'):
        if args.no_html_info:
            output_summary='HTML output not saved (--no-html-info).'
        else:
            html_path=outdir/'output.html'
            html_path.write_text(result['lst'],encoding='utf-8')
            output_summary='HTML output saved to: '+str(html_path)
            if os.environ.get('OPEN_RESULT','1').lower() in ('1','true','yes','on') and not args.json:
                open_result_html(html_path)
    preflight=json.dumps(advisories)
    if plan.macro_dir_warning:
        preflight+='\n'+plan.macro_dir_warning
    report='=== Submission Preflight ===\n'+preflight+'\n=== SAS Log ===\n'+result.get('log','')+'\n=== Output ===\n'+output_summary
    if result.get('error'):
        report+='\nERROR: '+result['error']+'\n'
    log_path=outdir/'output.html.info.txt'
    log_path.write_text(report,encoding='utf-8')
    if result.get('processed_code'):
        (outdir/'submitted.sas').write_text(result['processed_code'],encoding='utf-8')
    result.update(exit_code=code_exit,log_path=str(log_path),runtime='python')
    atomic_json(outdir/'result.json',result)
    status.update(state='completed' if code_exit==0 else 'timeout' if code_exit==124 else 'failed',complete=True,success=code_exit==0,exit_code=code_exit,finished_at=datetime.now(timezone.utc).isoformat(),log_path=str(log_path),failure_class=result['diagnostics']['failure_class'] or ('timeout' if code_exit==124 else 'runtime_error' if result.get('error') else ''))
    atomic_json(status_path,status)
    print(json.dumps(result,ensure_ascii=False) if args.json else report+'\nSAS log for debugging saved to: '+str(log_path)+'\n'+diagnostics.format_summary(result['diagnostics']))
    return code_exit

def main(argv=None):
    try:
        p=parser()
        args=p.parse_args(argv)
        if argv==[] or (argv is None and len(sys.argv)==1):
            p.print_help()
            return 0
        if argv is None:
            ensure_saspy_environment(args)
        return execute(args)
    except (OSError,ValueError) as exc:
        print('MCP4SAS Python: '+str(exc),file=sys.stderr)
        return 2

if __name__=='__main__':
    raise SystemExit(main())
