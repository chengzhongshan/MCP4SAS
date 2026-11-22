#!/usr/bin/env python3
"""Opt-in live regression: preserve WORK.A across independent CLI invocations.

Configure SASPy normally, then run:
  python tests/run_live_persistent_print.py --language perl --out RESULTS
  python tests/run_live_persistent_print.py --language python --out RESULTS

Uses a fresh test session/server, never the user's existing named session.
The output records wall time; it does not impose hardware-specific speed limits.
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
    parser.add_argument('--language',choices=['perl','python'],required=True)
    parser.add_argument('--perl',default=shutil.which('perl'))
    parser.add_argument('--out',type=Path,required=True)
    args=parser.parse_args()
    out=args.out.resolve();out.mkdir(parents=True,exist_ok=False)
    interpreter=args.perl if args.language=='perl' else sys.executable
    if not interpreter: parser.error('Perl executable not found; use --perl')
    env=dict(os.environ,OPEN_RESULT='0',SAS_ODA_AUTOLOAD_MACROS='0')
    # Port reservation is released just before starting our own service.
    with socket.socket() as probe:
        probe.bind(('127.0.0.1',0));port=probe.getsockname()[1]
    env['SAS_ODA_SESSION_PORT']=str(port)
    session='test_print_'+str(os.getpid())+'_'+str(time.time_ns())
    script=str(ROOT/('run_sas_codes_or_files_in_ODA.'+('pl' if args.language=='perl' else 'py')))
    cygpath=Path(interpreter).with_name('cygpath.exe')
    if args.language=='perl' and os.name=='nt' and cygpath.is_file():
        script=subprocess.check_output([str(cygpath),'-u',script],env=env,text=True).strip()
    records=[]
    common=[interpreter,script,'--persistent','--session-id',session,'--no-open-html']
    codes=[('create','options notes; data a;set sashelp.class;run; %put TEST_PRINT_PID=&sysjobid;'),
           ('implicit_print','proc print;run; %put TEST_PRINT_PID=&sysjobid;'),
           ('explicit_print','proc print data=work.a;run; %put TEST_PRINT_PID=&sysjobid;'),
           ('large_implicit_print','/* saved macro library placeholder */\n'*10000+
            'proc print;run; %put TEST_PRINT_PID=&sysjobid;')]
    try:
        pids=[]
        for name,code in codes:
            start=time.monotonic()
            # Windows command lines cannot carry a macro library of this size.
            # Use the same saved-file entry point as the real PoC examples.
            if len(code)>16000:
                source=out/(name+'.sas');source.write_text(code,encoding='utf-8')
                request=['--file',source.name]
            else:
                request=['--code',code]
            result=subprocess.run(common+request+['--output-prefix',name],cwd=out,env=env,
                                  stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=300)
            (out/(name+'.console.log')).write_bytes(result.stdout)
            log=(out/name/'output.html.info.txt').read_text(encoding='utf-8',errors='replace')
            assert result.returncode==0, 'CLI failed: '+name
            assert not re.search(r'^\s*ERROR(?:\s+\d+[-:]|:)',log,re.M),log
            pid=re.search(r'^TEST_PRINT_PID=(\S+)',log,re.M)
            assert pid,'missing PID marker';pids.append(pid[1])
            if 'print' in name:
                assert re.search(r'19 observations read from the data set WORK\.A',log),log
                html=list((out/name).glob('*.html'))
                assert html and any('Alfred' in f.read_text(errors='replace') for f in html),'CLASS HTML missing'
            records.append(dict(stage=name,seconds=round(time.monotonic()-start,3),pid=pid[1],exit_code=result.returncode))
            print(json.dumps(records[-1]),flush=True)
        assert len(set(pids))==1,'persistent SAS PID changed'
    finally:
        # End only the unique session owned by this invocation.
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
        (out/'timings.json').write_text(json.dumps(records,indent=2)+'\n')
    print('PASS: same SAS PID; implicit and explicit PRINT returned 19 WORK.A rows and saved HTML.')

if __name__=='__main__': main()
