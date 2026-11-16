#!/usr/bin/env python3
"""Opt-in live comparison of the configured VS Code relay and direct runners.

Uses the selected SAS target, fresh sessions and the same small SASHELP program.
Never changes VS Code settings, credentials, macros or the selected target.
No AI model is called; response bytes are not token/cost measurements.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import queue
import re
import shutil
import subprocess
import threading
import time

ROOT=Path(__file__).resolve().parents[1]
PROGRAM=('proc print data=sashelp.class(obs=5); run;\n'
         'proc sql noprint; select count(*) into :route_n trimmed from sashelp.class; quit;\n'
         '%put MCPROUTE_COUNT=&route_n;\n')

def posix(path,config):
    if os.name!='nt':return str(path)
    converter=Path(config['perl']).with_name('cygpath.exe')
    if not converter.is_file():return Path(path).as_posix()
    return subprocess.check_output([str(converter),'-u',str(path)],text=True).strip()

class Relay:
    def __init__(self,node,config,out,env):
        self.queue=queue.Queue();self.ident=0;self.calls=0;self.bytes=0
        self.log=(out/'relay.stderr.txt').open('w',encoding='utf8')
        self.process=subprocess.Popen([node,str(ROOT/'integrations/vscode/src/relay.js'),'--config',str(config)],cwd=ROOT,env=env,stdin=subprocess.PIPE,stdout=subprocess.PIPE,stderr=self.log,text=True,bufsize=1)
        def read():
            try:
                for line in self.process.stdout:self.queue.put(json.loads(line))
            finally:self.queue.put(None)
        threading.Thread(target=read,daemon=True).start()
    def request(self,method,params=None):
        self.ident+=1;self.calls+=method=='tools/call'
        self.process.stdin.write(json.dumps(dict(jsonrpc='2.0',id=self.ident,method=method,params=params or {}))+'\n');self.process.stdin.flush()
        response=self.queue.get(timeout=180)
        if response is None:raise RuntimeError('Relay stopped; inspect relay.stderr.txt. The request has not been replayed.')
        self.bytes+=len(json.dumps(response).encode())
        if response.get('error'):raise RuntimeError(response['error'])
        return response['result']
    def close(self):
        self.process.stdin.close()
        try:self.process.wait(timeout=10)
        except subprocess.TimeoutExpired:self.process.terminate();self.process.wait(timeout=10)
        self.log.close()

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--live',action='store_true',required=True)
    p.add_argument('--runtime-config',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True)
    p.add_argument('--node',default=shutil.which('node'))
    p.add_argument('--repo',type=Path,help='Optional configured MCP4SAS source override; must have installed Perl dependencies.')
    p.add_argument('--routes',nargs='+',choices=['python','perl','mcp'],default=['python','mcp','perl'])
    p.add_argument('--repeat',type=int,default=2)
    p.add_argument('--wait-seconds',type=float,default=20)
    p.add_argument('--poll-seconds',type=float,default=5)
    p.add_argument('--case',choices=['success','sas_error'],default='success')
    a=p.parse_args()
    if not a.node or a.repeat<1 or not 0<=a.wait_seconds<=30 or not .1<=a.poll_seconds<=30:p.error('Check node, repeat, wait and polling arguments.')
    config=json.loads(a.runtime_config.read_text(encoding='utf8'))
    if a.repo:config['repo']=str(a.repo.resolve())
    a.out=a.out.resolve();a.out.mkdir(parents=True,exist_ok=False)
    code=PROGRAM if a.case=='success' else 'proc print data=work.__route_missing__;run;\n'
    # The private file contains only the user's existing runtime metadata. It is
    # not copied into the public report, and the original remains untouched.
    private=a.out/'runtime.private.json'
    config['cwd']=str(a.out)
    private.write_text(json.dumps(config),encoding='utf8')
    js="const c=require('./integrations/vscode/src/core');c.runtimeEnvironment(JSON.parse(require('fs').readFileSync(process.argv[1],'utf8'))).then(e=>process.stdout.write(JSON.stringify(e)));"
    env=json.loads(subprocess.check_output([a.node,'-e',js,str(private)],cwd=ROOT,text=True))
    env['OPEN_RESULT']='0';env['SAS_ODA_AUTOLOAD_MACROS']='0'
    records=[];relay=None
    try:
        for repeat in range(a.repeat):
            routes=a.routes if repeat%2==0 else list(reversed(a.routes))
            for route in routes:
                directory=a.out/f'{repeat+1}-{route}';directory.mkdir()
                source=directory/'input.sas';source.write_text(code,encoding='utf8')
                record=dict(repeat=repeat+1,route=route,profile=config.get('saspyCfgname','oda'),case=a.case,persistent=False,code_sha256=hashlib.sha256(code.encode()).hexdigest())
                if route=='mcp':
                    if relay is None:
                        stamp=time.monotonic();relay=Relay(a.node,private,a.out,env)
                        relay.request('initialize',dict(protocolVersion='2024-11-05',capabilities={},clientInfo=dict(name='MCP4SAS-controlled-benchmark',version='1')))
                        record['cold_start_seconds']=round(time.monotonic()-stamp,4)
                    before=relay.calls;beforebytes=relay.bytes;stamp=time.monotonic()
                    result=relay.request('tools/call',dict(name='run_sas_codes_or_files_in_ODA',arguments=dict(sas_codes_or_file=code,persistent='false',wait_seconds=a.wait_seconds)))
                    deadline=stamp+240
                    while result.get('structuredContent',{}).get('status')=='RUNNING':
                        if time.monotonic()>deadline:raise TimeoutError('Existing SAS job remains unconfirmed; not replayed.')
                        time.sleep(a.poll_seconds)
                        result=relay.request('tools/call',dict(name='run_sas_codes_or_files_in_ODA',arguments=dict(pid=result['structuredContent']['pid'],wait_seconds=20)))
                    record.update(seconds=round(time.monotonic()-stamp,4),exit_code=result.get('structuredContent',{}).get('exit_code'),tool_calls=relay.calls-before,response_bytes=relay.bytes-beforebytes,status=result.get('structuredContent',{}).get('status'))
                    (directory/'response.json').write_text(json.dumps(result,indent=2),encoding='utf8')
                    logpath=result.get('structuredContent',{}).get('log_path')
                    logs=[Path(subprocess.check_output([str(Path(config['perl']).with_name('cygpath.exe')),'-w',logpath],text=True).strip()) if os.name=='nt' and logpath.startswith('/cygdrive/') else Path(logpath)] if logpath else []
                else:
                    command=[config['perl'],posix(Path(config['repo'])/'run_sas_codes_or_files_in_ODA.pl',config)] if route=='perl' else [config['python'],str(Path(config['repo'])/'run_sas_codes_or_files_in_ODA.py')]
                    command+=['--file',posix(source,config) if route=='perl' else str(source),'--output-prefix',posix(directory/'result',config) if route=='perl' else str(directory/'result'),'--saspy-cfgname',config.get('saspyCfgname','oda'),'--no-open-html']
                    if config.get('saspyCfgfile'):command+=['--saspy-cfgfile',config['saspyCfgfile']]
                    stamp=time.monotonic()
                    with (directory/'runner.stdout.txt').open('w',encoding='utf8') as log:
                        completed=subprocess.run(command,cwd=a.out,env=env,stdout=log,stderr=subprocess.STDOUT,timeout=240)
                    record.update(seconds=round(time.monotonic()-stamp,4),exit_code=completed.returncode,tool_calls=0)
                    logs=list(directory.rglob('output.html.info.txt'))
                text='\n'.join(path.read_text(encoding='utf8',errors='replace') for path in logs if path.is_file())
                record['passed']=(record['exit_code']==0 and 'MCPROUTE_COUNT=19' in text and not re.search(r'^ERROR(?:\s+\d+-\d+)?:',text,re.M)) if a.case=='success' else (record['exit_code']==1 and re.search(r'ERROR: File WORK\.__ROUTE_MISSING__\.DATA does not exist',text,re.I) is not None)
                if a.case=='success':record['passed']=record['passed'] and any(path.is_file() and list(path.parent.glob('*.html')) for path in logs)
                records.append(record)
                (a.out/'measurements.json').write_text(json.dumps(records,indent=2),encoding='utf8')
                print(json.dumps(record),flush=True)
    finally:
        if relay:relay.close()
    return int(not all(row['passed'] for row in records))

if __name__=='__main__':raise SystemExit(main())
