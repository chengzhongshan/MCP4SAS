"""Python SAS runner. Help, dry-run and log classification need no SASPy."""
import argparse
from datetime import datetime,timezone
import getpass
import json
import os
from pathlib import Path
import re
import secrets
import sys
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

def parser():
    p=argparse.ArgumentParser(description='Run SAS through a native Python MCP4SAS runtime; no Perl required.',allow_abbrev=False)
    group=p.add_mutually_exclusive_group()
    group.add_argument('--code','--codes','-c')
    group.add_argument('--file','-file','-f')
    p.add_argument('--macro-dir','-m')
    p.add_argument('--output-prefix','-p')
    p.add_argument('--session-id','-s')
    p.add_argument('--persistent',action=argparse.BooleanOptionalAction,default=None)
    p.add_argument('--skip-upload-if-same',action=argparse.BooleanOptionalAction,default=True)
    p.add_argument('--archive-transfers',action=argparse.BooleanOptionalAction,default=True)
    p.add_argument('--cleanup-empty-output-dir',action=argparse.BooleanOptionalAction,default=True)
    p.add_argument('--keep-intermediate-files',action=argparse.BooleanOptionalAction,default=False)
    for name,alias in [('upload-file','-u'),('download-file','-d'),('delete-file','-k'),('dir4listing','-l')]:
        p.add_argument('--'+name,alias,action='append' if name!='dir4listing' else 'store',default=[] if name!='dir4listing' else None)
    for name in ('download-local-path','delete-file-rgx','delete-directory-rgx','file-info'):
        p.add_argument('--'+name,action='append',default=[])
    p.add_argument('--delete-directory-dry-run',action='store_true')
    p.add_argument('--delete-dir',default='~')
    p.add_argument('--saspy-cfgname',default=os.environ.get('SASPY_CFGNAME') or os.environ.get('SASPY_CONFIG_NAME') or 'oda')
    generated_config=Path(__file__).parent/'.saspy-config/sascfg_personal.py'
    p.add_argument('--saspy-cfgfile',default=os.environ.get('SASPY_CFGFILE') or (str(generated_config) if generated_config.is_file() else None))
    p.add_argument('--dir4local_sas_home')
    p.add_argument('--classify-sas-log')
    p.add_argument('--run-timeout-seconds',type=int,default=int(os.environ.get('SAS_ODA_RUN_TIMEOUT_SECONDS','3600')))
    p.add_argument('--run-timeout-grace-seconds',type=int,default=15,help='Accepted compatibility option; owned backend is terminated on timeout.')
    p.add_argument('--no-run-timeout',action='store_true')
    p.add_argument('--no-html-info','--no-html_info',action='store_true')
    p.add_argument('--dry-run',action='store_true')
    p.add_argument('--json',action='store_true',help='Print machine-readable outcome rather than a text report.')
    p.add_argument('--monitor-status-file')
    p.add_argument('--monitor-interval-seconds',type=int,default=5)
    p.add_argument('--check-sas-oda-login-only','--check-saspy-connection-only',action='store_true')
    p.add_argument('--prompt-sas-oda-auth',action='store_true')
    p.add_argument('--sas-oda-account')
    p.add_argument('--sas-oda-password',help=argparse.SUPPRESS)
    p.add_argument('--skip-sas-oda-auth-bootstrap',action='store_true')
    p.add_argument('--kill-saspy-sessions','--kill-sas-oda-sessions','--kill-saspy-session-server',action='store_true',help='Close only this Python runtime/session, not unrelated Perl or Java processes.')
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
    if args.run_timeout_seconds<0:
        raise ValueError('Timeout must be nonnegative')
    if args.session_id and not re.fullmatch(r'[A-Za-z0-9_-]+',args.session_id):
        raise ValueError('Use letters, numbers, underscores or hyphens in a session ID')
    persistent=args.persistent if args.persistent is not None else bool(args.session_id)
    session_id=(args.session_id or 'default_session') if persistent else None
    code=read_source(args.file) if args.file else sys.stdin.read() if args.code=='-' else args.code or ''
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
    configure_credentials(args)
    from .runner import Runner
    timeout=0 if args.no_run_timeout else args.run_timeout_seconds
    local_home=None
    if args.dir4local_sas_home:
        local_home=str(Path(args.dir4local_sas_home).resolve())
        Path(local_home).mkdir(parents=True,exist_ok=True)
    outdir=Path(args.output_prefix or 'SAS_Output_Python_'+datetime.now().strftime('%Y%m%d_%H%M%S')+'_'+secrets.token_hex(4)).resolve()
    outdir.mkdir(parents=True,exist_ok=True)
    status_path=outdir/'output.html.run.status.json'
    started=datetime.now(timezone.utc).isoformat()
    status=dict(state='running',complete=False,success=False,started_at=started,pid=os.getpid(),runtime='python',session_id=session_id)
    atomic_json(status_path,status)
    result=dict(log='',lst='',diagnostics=diagnostics.classify(''),advisories=advisories)
    code_exit=0
    try:
        with Runner(session_id=session_id,timeout=timeout,cfgname=args.saspy_cfgname,cfgfile=args.saspy_cfgfile,local_home=local_home,archive_transfers=args.archive_transfers,skip_upload_if_same=args.skip_upload_if_same) as runner:
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
    report='=== Submission Preflight ===\n'+json.dumps(advisories)+'\n=== SAS Log ===\n'+result.get('log','')+'\n=== Output ===\n'+result.get('lst','')
    if result.get('error'):
        report+='\nERROR: '+result['error']+'\n'
    log_path=outdir/'output.html.info.txt'
    log_path.write_text(report,encoding='utf-8')
    if result.get('lst') and not args.no_html_info:
        html=outdir/'output.html'
        html.write_text(result['lst'],encoding='utf-8')
        if os.environ.get('OPEN_RESULT','0').lower() in ('1','true','yes','on'):
            webbrowser.open(html.as_uri())
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
        return execute(parser().parse_args(argv))
    except (OSError,ValueError) as exc:
        print('MCP4SAS Python: '+str(exc),file=sys.stderr)
        return 2

if __name__=='__main__':
    raise SystemExit(main())
