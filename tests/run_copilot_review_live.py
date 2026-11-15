"""Opt-in runner review against one configured SAS target; never prompts for credentials."""
import argparse
import json
import os
from pathlib import Path
import re
import secrets
import subprocess
import sys
import time

ROOT=Path(__file__).resolve().parents[1]

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--live',action='store_true',required=True)
    parser.add_argument('--out',required=True);parser.add_argument('--perl')
    parser.add_argument('--saspy-cfgname',default='oda');parser.add_argument('--saspy-cfgfile')
    args=parser.parse_args()
    out=Path(args.out).resolve();out.mkdir(parents=True,exist_ok=False)
    macro=out/'review_class.sas'
    macro.write_text('%macro review_class; proc print data=sashelp.class(obs=3); run; %mend;\n',encoding='utf-8')
    code='%review_class; proc sql noprint; select count(*) into :review_n trimmed from sashelp.class;quit;%put REVIEW_COUNT=&review_n;'
    session='review_'+secrets.token_hex(8)
    env=dict(os.environ,OPEN_RESULT='0',SAS_ODA_AUTOLOAD_MACROS='0',PYTHONUNBUFFERED='1')
    env.pop('PIPELINE_PYTHON_BIN',None)
    target=['--saspy-cfgname',args.saspy_cfgname]
    config=Path(args.saspy_cfgfile) if args.saspy_cfgfile else ROOT/'MCP4SAS_Use_Python/.saspy-config/sascfg_personal.py'
    if config.is_file(): target+=['--saspy-cfgfile',config.resolve().as_posix()]
    elif args.saspy_cfgfile: raise FileNotFoundError(config)
    records=[]
    def run(name,command,extra,expected,marker=None,fallback=False,reexec=False):
        directory=out/name
        command=command+target+['--output-prefix',directory.as_posix()]+extra
        runtime_env=dict(env)
        if name.startswith('perl'): runtime_env['PIPELINE_PYTHON_BIN']=Path(sys.executable).as_posix()
        start=time.perf_counter()
        result=subprocess.run(command,cwd=out,env=runtime_env,capture_output=True,text=True,timeout=150)
        directory.mkdir(exist_ok=True)
        (directory/'terminal.stdout.txt').write_text(result.stdout,encoding='utf-8')
        (directory/'terminal.stderr.txt').write_text(result.stderr,encoding='utf-8')
        log_path=directory/'output.html.info.txt'
        log=log_path.read_text(encoding='utf-8',errors='replace') if log_path.exists() else ''
        status_files=list(directory.glob('*.run.status.json'))
        status=json.loads(status_files[0].read_text(encoding='utf-8')) if status_files else {}
        problems=[]
        if result.returncode!=expected: problems.append(f'Exit {result.returncode}, expected {expected}')
        if not log: problems.append('Complete log missing')
        if expected==1 and not re.search(r'^\s*ERROR:\s+File WORK\.__REVIEW_MISSING__\.DATA does not exist',log,re.I|re.M): problems.append('Expected SAS missing-table diagnostic absent')
        if marker and not re.search('^'+re.escape(marker)+r'\s*$',log,re.M): problems.append('Computed marker missing')
        if fallback and 'using the current working directory' not in log: problems.append('Fallback warning missing')
        if reexec and 'restarting with the SASPy environment' not in result.stderr: problems.append('Interpreter handoff missing')
        if not name.startswith('perl') and re.search(r'<(?:html|!doctype html)\b',result.stdout,re.I): problems.append('Raw HTML leaked into terminal')
        if not name.startswith('perl') and status.get('exit_code')!=expected: problems.append('Status JSON inconsistent')
        record=dict(case=name,exit_code=result.returncode,expected_exit=expected,passed=not problems,problems=problems,
                    seconds=round(time.perf_counter()-start,3),stdout_bytes=len(result.stdout.encode()),log_bytes=len(log.encode()),
                    html_bytes=sum(p.stat().st_size for p in directory.glob('*.html')),interpreter_handoff=reexec)
        records.append(record)
        (out/'execution.json').write_text(json.dumps(dict(target=args.saspy_cfgname,cases=records),indent=2)+'\n',encoding='utf-8')
        print(json.dumps(record),flush=True)
        return record
    python=[sys.executable,str(ROOT/'run_sas_codes_or_files_in_ODA.py')]
    persistent=['--session-id',session]
    try:
        run('python_macro',python,persistent+['--code',code,'--macro-dir',str(out/'missing_macros')],0,'REVIEW_COUNT=19',fallback=True)
        run('python_environment_handoff',[sys.executable,'-S',str(ROOT/'run_sas_codes_or_files_in_ODA.py')],persistent+['--code',code],0,'REVIEW_COUNT=19',reexec=True)
        if args.perl:
            perl=[args.perl,(ROOT/'run_sas_codes_or_files_in_ODA.pl').as_posix()]
            run('perl_macro',perl,['--code',code,'--macro-dir',str(out/'missing_macros')],0,'REVIEW_COUNT=19',fallback=True)
            run('perl_expected_error',perl,['--code','proc print data=work.__review_missing__;run;'],1)
        run('python_expected_error',python,persistent+['--code','proc print data=work.__review_missing__;run;'],1)
        literal=r'%let review_path=C:\new\table.tsv; %put REVIEW_PATH=%superq(review_path);'
        run('python_literal_path',python,persistent+['--code',literal],0,r'REVIEW_PATH=C:\new\table.tsv')
        run('python_timeout',python,persistent+['--code','data _null_;call sleep(20,1);run;','--run-timeout-seconds','2','--run-timeout-grace-seconds','1'],124)
        run('python_recovery',python,persistent+['--code',code],0,'REVIEW_COUNT=19')
    finally:
        run('python_session_close',python,persistent+['--kill-saspy-sessions'],0)
    return 0 if all(r['passed'] for r in records) else 1

if __name__=='__main__': raise SystemExit(main())
