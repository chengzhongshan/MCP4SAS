#!/usr/bin/env python3
"""Run the original Perl live tests on isolated test-only backend/HTTP ports.

This is a maintainer orchestrator, not the Python runner counterpart. It records
real exit codes, TAP failures, selected variants, and retained SAS artifact paths.
"""
import argparse
import json
import os
from pathlib import Path
import re
import socket
import subprocess
import sys
import time

ROOT=Path(__file__).resolve().parents[1]


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--live',action='store_true',required=True)
    p.add_argument('--perl',required=True)
    p.add_argument('--out',type=Path,required=True)
    p.add_argument('--only',help='Exact test stem (optional)')
    p.add_argument('--corpora',action='store_true')
    args=p.parse_args()
    args.out.mkdir(parents=True,exist_ok=True)
    # Refuse to share a server with unrelated work.
    sockets=[]
    for _ in range(2):
        s=socket.socket();s.bind(('127.0.0.1',0));sockets.append(s)
    backend_port,http_port=[s.getsockname()[1] for s in sockets]
    for s in sockets:s.close()
    env=dict(os.environ,OPEN_RESULT='0',SAS_ODA_AUTOLOAD_MACROS='0',
             PIPELINE_PYTHON_BIN=Path(sys.executable).as_posix(),
             SASPY_CFGNAME='oda',SASPY_CFGFILE=(ROOT/'MCP4SAS_Use_Python/.saspy-config/sascfg_personal.py').as_posix(),
             SAS_ODA_SESSION_PORT=str(backend_port))
    variants=[]
    for file in sorted((ROOT/'tests').glob('test_live_*.pl')):
        variants.append((file,['--live']))
    variants.extend((ROOT/'tests'/name,['--live']) for name in ('run_live_cli_cleanup.pl','run_live_examples.pl','run_live_mcp_examples.pl','check_library_diagnostics_live.pl'))
    variants.extend([(ROOT/'tests/test_live_resolve_macro_loading.pl',['--live','--mode','unquote']),
                     (ROOT/'tests/test_live_remote_directory_cleanup.pl',['--live','--oneshot'])])
    if args.corpora:
        variants.extend((ROOT/'tests/run_live_library500.pl',['--live','--round',str(i)]) for i in (1,2,3,4,5,6,7,8,10))
        variants.append((ROOT/'tests/run_live_macro_open_code50.pl',['--live','--raw']))
    if args.only:variants=[(f,v) for f,v in variants if f.stem==args.only]
    if not variants:p.error('No matching tests')
    records=[]
    server_log=(args.out/'http-server.log').open('wb')
    server=subprocess.Popen([args.perl,(ROOT/'server.pl').as_posix(),'daemon','-l',f'http://127.0.0.1:{http_port}'],cwd=ROOT,env=env,stdout=server_log,stderr=subprocess.STDOUT)
    try:
        for _ in range(60):
            if server.poll() is not None:raise RuntimeError('HTTP test server exited; inspect its log')
            try:
                with socket.create_connection(('127.0.0.1',http_port),timeout=.2):break
            except OSError:time.sleep(.2)
        else:raise TimeoutError('HTTP test server not ready')
        for i,(file,extra) in enumerate(variants):
            label=f'{i:02d}_{file.stem}'
            if 'round' in ' '.join(extra):label+='_'+extra[-1]
            if file.name in ('run_live_mcp_examples.pl','check_library_diagnostics_live.pl'):
                extra=extra+['--url',f'http://127.0.0.1:{http_port}/mcp']
            command=[args.perl,file.as_posix(),*extra]
            start=time.monotonic();log=args.out/(label+'.log')
            print('START '+label,flush=True)
            try:
                with log.open('wb') as handle:
                    proc=subprocess.run(command,cwd=ROOT,env=env,stdout=handle,stderr=subprocess.STDOUT,timeout=2400)
                code=proc.returncode
            except subprocess.TimeoutExpired:code=124
            text=log.read_text(encoding='utf-8',errors='replace')
            failure_count=len(re.findall(r'^not ok\b',text,re.M))
            row=dict(file=file.name,arguments=extra,exit_code=code,tap_failures=failure_count,
                     passed=code==0 and not failure_count,seconds=round(time.monotonic()-start,3),log=str(log))
            records.append(row)
            (args.out/'execution.json').write_text(json.dumps(dict(backend_port=backend_port,http_port=http_port,results=records),indent=2)+'\n',encoding='utf-8')
            print(json.dumps(row),flush=True)
    finally:
        server.terminate()
        try:server.wait(timeout=10)
        except subprocess.TimeoutExpired:server.kill();server.wait()
        server_log.close()
        # Only the isolated server allocated by this invocation is addressed.
        try:
            with socket.create_connection(('127.0.0.1',backend_port),timeout=2) as sock:
                data=json.dumps({'cmd':'shutdown'}).encode()
                sock.sendall(len(data).to_bytes(8,'big')+data)
                sock.recv(8)
        except OSError:pass
    return int(any(not row['passed'] for row in records))


if __name__=='__main__':raise SystemExit(main())
