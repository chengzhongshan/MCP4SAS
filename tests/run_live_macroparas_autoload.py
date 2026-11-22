#!/usr/bin/env python3
"""Opt-in regression for automatic macroparas loading and saved HTML.

Configure SASPy, then run with --live --language perl|python --out NEW_DIRECTORY.
Uses a unique session/port and preserves all user sessions. No GTEx API or
scientific analysis is executed; this inspects the configured macro library.
"""
import argparse
import json
import os
from pathlib import Path
import re
import shutil
import socket
import subprocess
import sys
import time

ROOT=Path(__file__).resolve().parents[1]


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--live',action='store_true')
    parser.add_argument('--language',choices=('perl','python'),required=True)
    parser.add_argument('--perl',default=shutil.which('perl'))
    parser.add_argument('--out',type=Path,required=True)
    parser.add_argument('--expected-matches',type=int,help='Expected GTEx count in this library; versions differ.')
    args=parser.parse_args()
    if not args.live: parser.error('Actual SAS execution requires --live.')
    out=args.out.resolve();out.mkdir(parents=True,exist_ok=False)
    interpreter=args.perl if args.language=='perl' else sys.executable
    if not interpreter: parser.error('Perl not found; pass --perl.')
    env=dict(os.environ,OPEN_RESULT='0',SAS_ODA_AUTOLOAD_MACROS='0',
             MCP4SAS_PYTHON_STATE_DIR=str(out/'backend-state'))
    with socket.socket() as probe:
        probe.bind(('127.0.0.1',0));port=probe.getsockname()[1]
    env['SAS_ODA_SESSION_PORT']=str(port)
    session='test_macroparas_'+str(os.getpid())+'_'+str(time.time_ns())
    script=str(ROOT/('run_sas_codes_or_files_in_ODA.'+('pl' if args.language=='perl' else 'py')))
    cygpath=Path(interpreter).with_name('cygpath.exe')
    def local_path(value):
        if args.language=='perl' and os.name=='nt' and cygpath.is_file():
            return subprocess.check_output([str(cygpath),'-u',str(value)],env=env,text=True).strip()
        return str(value)
    common=[interpreter,local_path(script),'--persistent','--session-id',session,'--no-open-html']
    fixture=out/'macroparas_fixture.sas'
    fixture.write_text((ROOT/'tests/macroparas_gtex_regression.sas').read_text().replace(
        '"examples/sas_macros/macroparas_portable.sas"',
        '"'+local_path(ROOT/'examples/sas_macros/macroparas_portable.sas').replace('"','""')+'"'),encoding='utf-8')
    verify="""data _null_; set work.mcp_macroparas_sentinel;
if sentinel=42 then put 'PASS: SENTINEL_RETAINED'; else put 'ERROR: SENTINEL_CHANGED'; run;
data _null_; ds=open('work.macro_paras');
if ds>0 then do; n=attrn(ds,'nobs'); rc=close(ds); put 'PASS: MACROPARAS_ROWS=' n; end;
else put 'ERROR: MISSING_RESULT'; run;"""
    jobs=[('legacy',['--file',local_path(ROOT/'tests/macroparas_autoload_regression.sas')]),
          ('gtex',['--code','%macroparas(macrorgx=GTEx);proc print;run;']),
          ('verify',['--code',verify]),
          ('regression',['--file',local_path(fixture)])]
    records=[]
    try:
        for name,request in jobs:
            start=time.monotonic()
            result=subprocess.run(common+request+['--output-prefix',name],cwd=out,env=env,
                                  stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=300)
            (out/(name+'.console.log')).write_bytes(result.stdout)
            log=(out/name/'output.html.info.txt').read_text(encoding='utf-8',errors='replace')
            assert result.returncode==0,'CLI failed: '+name
            assert not re.search(r'^\s*ERROR(?:\s+\d+[-:]|:)',log,re.M),'SAS error: '+name
            assert 'Invalid argument to function' not in log and '_ERROR_=1' not in log,'DATA step diagnostic: '+name
            if name=='gtex':
                match=re.search(r'^MACROPARAS_MATCH_COUNT=(\d+)',log,re.M)
                assert match,'Missing count marker'
                count=int(match[1])
                if args.expected_matches is not None: assert count==args.expected_matches,(count,args.expected_matches)
                if count: assert list((out/name).glob('*.html')),'Missing HTML'
            if name=='verify': assert re.search(r'^PASS: SENTINEL_RETAINED',log,re.M),'WORK changed'
            if name=='regression':
                markers=set(re.findall(r'^MACROPARAS_TEST_PASS=(\S+)',log,re.M))
                assert len(markers)==10,(len(markers),markers)
            records.append(dict(stage=name,seconds=round(time.monotonic()-start,3),exit_code=result.returncode))
            print(json.dumps(records[-1]),flush=True)
    finally:
        close=['--code','endsas;'] if args.language=='perl' else ['--kill-saspy-sessions']
        try:
            ended=subprocess.run(common+close+['--output-prefix','close'],cwd=out,env=env,
                                 stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=60)
            (out/'close.console.log').write_bytes(ended.stdout)
        except subprocess.TimeoutExpired: pass
        if args.language=='perl':
            try:
                with socket.create_connection(('127.0.0.1',port),timeout=5) as conn:
                    data=json.dumps({'cmd':'shutdown'}).encode()
                    conn.sendall(len(data).to_bytes(8,'big')+data)
                    conn.recv(4096)
            except OSError: pass
        (out/'results.json').write_text(json.dumps(records,indent=2)+'\n',encoding='utf-8')
    print('PASS: automatic macro loading, persistent WORK, HTML and ten macro assertions.')


if __name__=='__main__': main()
