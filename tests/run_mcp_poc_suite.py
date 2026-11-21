#!/usr/bin/env python3
"""Opt-in four-case PoC through actual Perl HTTP and Python SDK stdio MCP.

Owns separate server/session resources; never switches the VS Code target or
uses Perl's global session-kill option. Requires installed SASPy/ODA access.
"""
import argparse
import asyncio
import hashlib
import json
import os
from pathlib import Path
import re
import socket
import subprocess
import sys
import time
import urllib.request

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT))
from MCP4SAS_Use_Python.poc import validate
from MCP4SAS_Use_Python.transport import stop_owned_pid
CASES=('clustergram','gene_gtf','oncoprint','forest')

def port():
    with socket.socket() as s:s.bind(('127.0.0.1',0));return s.getsockname()[1]

def local_path(value):
    if os.name=='nt' and str(value).startswith('/cygdrive/'):
        return Path(str(value)[10]+':/'+str(value)[12:])
    return Path(value)

async def evaluate(call,out,language,session,args,manifest):
    rows=[];sequence=0
    async def tool(arguments,label):
        nonlocal sequence
        sequence+=1;result=await call(arguments)
        (out/f'{sequence:02d}_{label}.json').write_text(json.dumps(result,indent=2),encoding='utf8')
        deadline=time.monotonic()+900
        while result.get('structuredContent',{}).get('status')=='RUNNING':
            if time.monotonic()>deadline:raise TimeoutError('Job remains unconfirmed; it has not been replayed.')
            await asyncio.sleep(5);sequence+=1
            result=await call(dict(pid=result['structuredContent']['pid']))
            (out/f'{sequence:02d}_{label}_poll.json').write_text(json.dumps(result,indent=2),encoding='utf8')
        if result.get('isError') or result.get('structuredContent',{}).get('status')!='COMPLETE':raise RuntimeError(str(result))
        return result
    common=dict(persistent='true',session_id=session,saspy_cfgname='oda',saspy_cfgfile=str(args.saspy_cfgfile),run_timeout_seconds=600)
    try:
        for identifier in CASES:
            case=next(c for c in manifest['cases'] if c['id']==identifier)
            directory=out/identifier;directory.mkdir()
            started=time.monotonic()
            # Sending exact saved text avoids native/Cygwin filename ambiguity.
            source=(ROOT/'examples/poc'/case['program']).read_text(encoding='utf8')
            result=await tool(dict(common,sas_codes_or_file=source,upload_file=[str(ROOT/'examples/poc'/i['file']) for i in case['inputs']]),identifier+'_submit')
            logpath=local_path(result['structuredContent']['log_path'])
            if not logpath.is_absolute():logpath=out/logpath
            log=logpath.read_text(encoding='utf8',errors='replace')
            (directory/'submitted.sas').write_text(source,encoding='utf8')
            (directory/'sas.log').write_text(log,encoding='utf8')
            if not re.search('^'+re.escape(case['completion_marker'])+r'\s*$',log,re.M):raise ValueError('Completion marker missing')
            if re.search(r'^\s*ERROR(?:\s+\d+-\d+)?:',log,re.M):raise ValueError('SAS errors in retained log')
            remote=re.search(r'^POC_OUT=([^\r\n]+)',log,re.M)
            if not remote:raise ValueError('WORK result location missing')
            files=directory/'files';files.mkdir()
            for name in case['files']:(files/name).parent.mkdir(parents=True,exist_ok=True)
            await tool(dict(common,download_file=[remote[1].strip()+'/'+name for name in case['files']],download_local_path=[str(files/name) for name in case['files']]),identifier+'_collect')
            checks=validate(identifier,files)
            row=dict(runner=language,case=identifier,checks=checks,seconds=round(time.monotonic()-started,3),warnings=re.findall(r'^WARNING:[^\r\n]*',log,re.M),passed=True,files={name:hashlib.sha256((files/name).read_bytes()).hexdigest() for name in case['files']})
            rows.append(row);(out/'execution.json').write_text(json.dumps(rows,indent=2),encoding='utf8');print(json.dumps({key:row[key] for key in ('runner','case','checks','seconds','passed')}),flush=True)
    finally:
        try:
            closing=await call(dict(common,kill_saspy_sessions=True) if language=='python' else dict(common,sas_codes_or_file='endsas;'))
            # End-SAS can legitimately return a connection-termination error.
            (out/'session_close.json').write_text(json.dumps(closing,indent=2),encoding='utf8')
        except Exception as error:(out/'session_close_error.txt').write_text(str(error),encoding='utf8')
    return rows

async def run(args):
    args.outdir=args.outdir.resolve();args.outdir.mkdir(parents=True,exist_ok=False)
    args.saspy_cfgfile=args.saspy_cfgfile.resolve(strict=True)
    manifest=json.loads((ROOT/'examples/poc/manifest.json').read_text())
    hashes={}
    for case in manifest['cases']:
        if case['id'] not in CASES:continue
        for item in [dict(file=case['program'],sha256=case['sha256']),*case['inputs']]:
            p=ROOT/'examples/poc'/item['file'];hashes[item['file']]=hashlib.sha256(p.read_bytes()).hexdigest()
            if hashes[item['file']]!=item['sha256']:raise ValueError('Frozen source changed: '+item['file'])
    env=dict(os.environ,OPEN_RESULT='0',SAS_ODA_AUTOLOAD_MACROS='0',PERLMCP_SASPY_LOAD_MACROS='0',SASPY_CFGNAME='oda',SASPY_CFGFILE=str(args.saspy_cfgfile),PIPELINE_PYTHON_BIN=args.python)
    report=dict(source_commit=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),source_hashes=hashes,records=[],complete=False)
    for language in ('perl','python'):
        out=args.outdir/language;out.mkdir();session='mcp_poc_'+language+'_'+str(os.getpid());backend_port=port()
        current=dict(env,SAS_ODA_SESSION_PORT=str(backend_port),MCP4SAS_PYTHON_STATE_DIR=str(out/'python-state'))
        if language=='perl':
            http_port=port();url=f'http://127.0.0.1:{http_port}/mcp'
            script=str(ROOT/'server.pl')
            if os.name=='nt':script=subprocess.check_output([str(Path(args.perl).with_name('cygpath.exe')),'-u',script],text=True).strip()
            with (out/'server.log').open('wb') as stream:
                process=subprocess.Popen([args.perl,script,'daemon','-m','production','-l',f'http://127.0.0.1:{http_port}'],cwd=out,env=current,stdout=stream,stderr=stream,start_new_session=os.name!='nt')
            ident=0
            def request(method,params=None):
                nonlocal ident
                ident+=1;body=json.dumps(dict(jsonrpc='2.0',id=ident,method=method,params=params or {})).encode()
                with urllib.request.urlopen(urllib.request.Request(url,data=body,headers={'Content-Type':'application/json'}),timeout=180) as r:reply=json.load(r)
                if 'error' in reply:raise RuntimeError(reply['error'])
                return reply['result']
            try:
                for attempt in range(100):
                    if process.poll() is not None:raise RuntimeError('Perl MCP stopped; inspect server.log')
                    try:request('tools/list');break
                    except OSError:await asyncio.sleep(.2)
                else:raise TimeoutError('Perl MCP startup')
                request('initialize',dict(protocolVersion='2024-11-05',capabilities={},clientInfo=dict(name='poc-validation',version='1')))
                async def call(arguments):return await asyncio.to_thread(request,'tools/call',dict(name='run_sas_codes_or_files_in_ODA',arguments=arguments))
                report['records']+=await evaluate(call,out,language,session,args,manifest)
            finally:
                try:
                    with socket.create_connection(('127.0.0.1',backend_port),timeout=5) as c:
                        data=json.dumps(dict(cmd='shutdown')).encode();c.sendall(len(data).to_bytes(8,'big')+data);c.recv(4096)
                except OSError:pass
                stop_owned_pid(process.pid,grace_seconds=.1,process=process)
        else:
            from mcp import ClientSession,StdioServerParameters
            from mcp.client.stdio import stdio_client
            parameters=StdioServerParameters(command=args.python,args=[str(ROOT/'server.py')],cwd=str(out),env=current)
            async with stdio_client(parameters) as (read,write):
                async with ClientSession(read,write) as client:
                    await client.initialize()
                    async def call(arguments):return (await client.call_tool('run_sas_codes_or_files_in_ODA',arguments)).model_dump(mode='json')
                    report['records']+=await evaluate(call,out,language,session,args,manifest)
        (args.outdir/'execution.json').write_text(json.dumps(report,indent=2),encoding='utf8')
    report['source_files_unchanged']=all(hashlib.sha256((ROOT/'examples/poc'/p).read_bytes()).hexdigest()==v for p,v in hashes.items())
    report['complete']=len(report['records'])==8 and report['source_files_unchanged']
    (args.outdir/'execution.json').write_text(json.dumps(report,indent=2),encoding='utf8')

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--live',action='store_true',required=True)
    parser.add_argument('--outdir',type=Path,required=True)
    parser.add_argument('--saspy-cfgfile',type=Path,required=True)
    parser.add_argument('--perl',default='perl')
    parser.add_argument('--python',default=sys.executable,help='Python with the MCP SDK and SASPy installed')
    asyncio.run(run(parser.parse_args()))
