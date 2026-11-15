#!/usr/bin/env python3
"""Maintainer orchestrator for all eight original MCP example catalogs.

Python selects the native SDK/Python runner. Perl selects the unchanged Perl
HTTP server/harness. This orchestrator is not a Python replacement for Perl.
"""
import argparse
import json
import os
from pathlib import Path
import socket
import subprocess
import sys
import time

ROOT=Path(__file__).resolve().parents[1]


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--runtime',choices=('perl','python'),required=True)
    mode=p.add_mutually_exclusive_group(required=True)
    mode.add_argument('--live',action='store_true');mode.add_argument('--generate-only',action='store_true')
    p.add_argument('--perl');p.add_argument('--batches',default='1,2,3,4,5,6,7,8');p.add_argument('--out',type=Path,required=True)
    p.add_argument('--only',help='Explicit selected IDs for a single batch; no failed job is replayed automatically.')
    args=p.parse_args()
    if args.runtime=='perl' and not args.perl:p.error('--perl is required for the original harness')
    batches=[int(v) for v in args.batches.split(',')]
    if len(set(batches))!=len(batches) or any(v not in range(1,9) for v in batches):p.error('Invalid --batches')
    if args.only and len(batches)!=1:p.error('--only requires exactly one --batches value')
    args.out=args.out.resolve();args.out.mkdir(parents=True,exist_ok=False)
    env=dict(os.environ,OPEN_RESULT='0',SAS_ODA_AUTOLOAD_MACROS='0',PIPELINE_PYTHON_BIN=Path(sys.executable).as_posix())
    env['SASPY_CFGNAME']='oda';env['SASPY_CFGFILE']=(ROOT/'MCP4SAS_Use_Python/.saspy-config/sascfg_personal.py').as_posix()
    def free_port():
        with socket.socket() as sock:sock.bind(('127.0.0.1',0));return sock.getsockname()[1]
    backend_port,http_port=free_port(),free_port()
    env['SAS_ODA_SESSION_PORT']=str(backend_port)
    server=None;server_log=None;records=[]
    try:
        if args.runtime=='perl' and args.live:
            server_log=(args.out/'http-server.log').open('wb')
            server=subprocess.Popen([args.perl,(ROOT/'server.pl').as_posix(),'daemon','-l',f'http://127.0.0.1:{http_port}'],cwd=ROOT,env=env,stdout=server_log,stderr=subprocess.STDOUT)
            for _ in range(100):
                if server.poll() is not None:raise RuntimeError('HTTP server exited')
                try:
                    with socket.create_connection(('127.0.0.1',http_port),timeout=.2):break
                except OSError:time.sleep(.2)
            else:raise TimeoutError('HTTP server did not start')
        for batch in batches:
            extension='.py' if args.runtime=='python' else '.pl'
            command=[sys.executable if args.runtime=='python' else args.perl,
                (ROOT/'tests'/('run_live_new_examples_30'+extension)).as_posix(),
                '--live' if args.live else '--generate-only','--batch',str(batch),
                '--out',(args.out/('batch'+str(batch))).as_posix()]
            if args.runtime=='perl' and args.live:command+=['--url',f'http://127.0.0.1:{http_port}/mcp']
            if args.only:command+=['--only',args.only]
            start=time.monotonic();print('START '+args.runtime+' batch '+str(batch),flush=True)
            with (args.out/('batch'+str(batch)+'.log')).open('wb') as log:
                result=subprocess.run(command,cwd=ROOT,env=env,stdout=log,stderr=subprocess.STDOUT,timeout=3600)
            row=dict(batch=batch,exit_code=result.returncode,seconds=round(time.monotonic()-start,3),runtime=args.runtime,mode='live' if args.live else 'generate-only',selected_ids=args.only)
            records.append(row);(args.out/'execution.json').write_text(json.dumps(records,indent=2)+'\n',encoding='utf-8')
            print(json.dumps(row),flush=True)
    finally:
        if server:
            server.terminate()
            try:server.wait(timeout=10)
            except subprocess.TimeoutExpired:server.kill();server.wait()
        if server_log:server_log.close()
        if args.runtime=='perl' and args.live:
            try:
                with socket.create_connection(('127.0.0.1',backend_port),timeout=2) as sock:
                    payload=json.dumps({'cmd':'shutdown'}).encode();sock.sendall(len(payload).to_bytes(8,'big')+payload);sock.recv(8)
            except OSError:pass
    return int(any(v['exit_code'] for v in records))


if __name__=='__main__':raise SystemExit(main())
