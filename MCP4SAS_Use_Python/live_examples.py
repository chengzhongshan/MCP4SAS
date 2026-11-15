"""Generate original SAS cases or explicitly run selected cases through MCP.

Generation is offline. Live execution requires --live, a configured SAS account,
and a server on the same computer so complete logs can be checked independently.
"""
import argparse
import asyncio
from contextlib import asynccontextmanager
import json
import os
from pathlib import Path
import re
import secrets
import sys
import time
from urllib.request import Request,urlopen
from .demo_catalogs import ROOT,generate

def save(path,value):
    Path(path).write_text(json.dumps(value,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')

@asynccontextmanager
async def client(out,url=None,legacy_http=False):
    if legacy_http:
        if not url: raise ValueError('--legacy-http requires --url')
        counter=0
        async def call(arguments):
            nonlocal counter
            counter+=1
            request=Request(url,data=json.dumps(dict(jsonrpc='2.0',id=counter,method='tools/call',params=dict(name='run_sas_codes_or_files_in_ODA',arguments=arguments))).encode(),headers={'Content-Type':'application/json'})
            def send():
                with urlopen(request,timeout=240) as response: body=json.load(response)
                if body.get('error'): raise RuntimeError(body['error'])
                return body['result']
            return await asyncio.to_thread(send)
        yield call
        return
    from mcp import ClientSession,StdioServerParameters
    from mcp.client.stdio import stdio_client
    from mcp.client.streamable_http import streamable_http_client
    transport=streamable_http_client(url) if url else stdio_client(StdioServerParameters(
        command=sys.executable,args=[str(ROOT/'server.py')],cwd=str(out),env=dict(os.environ,OPEN_RESULT='0')))
    async with transport as streams:
        async with ClientSession(streams[0],streams[1]) as session:
            await session.initialize()
            async def call(arguments):
                return (await session.call_tool('run_sas_codes_or_files_in_ODA',arguments)).model_dump(mode='json',exclude_none=True)
            yield call

async def completed(call,arguments,deadline_seconds):
    started=await call(arguments)
    info=started.get('structuredContent',{})
    text='\n'.join(c.get('text','') for c in started.get('content',[]))
    pid=info.get('pid')
    if not pid:
        match=re.search(r'PID: (\d+)',text)
        pid=int(match[1]) if match else None
    if started.get('isError') or not pid:
        raise RuntimeError(f'Job did not start: {text}')
    deadline=time.monotonic()+deadline_seconds
    while time.monotonic()<deadline:
        done=await call(dict(pid=pid))
        status=done.get('structuredContent',{}).get('status')
        if status not in ('RUNNING',None): return started,done
        await asyncio.sleep(1 if time.monotonic()<deadline-240 else 5)
    raise TimeoutError(f'Job {pid} remains unconfirmed; it has not been replayed')

def assess(case,done,batch):
    data=done.get('structuredContent',{})
    expected='FAILED' if case.get('fail') else 'COMPLETE'
    problems=[]
    if data.get('status')!=expected: problems.append(f'Expected {expected}, got {data.get("status")}')
    if bool(done.get('isError'))!=bool(case.get('fail')): problems.append('Wrong MCP isError flag')
    if data.get('exit_code') is None or bool(data['exit_code'])!=bool(case.get('fail')): problems.append('Wrong/missing exit code')
    path=Path(data.get('log_path') or '__missing_log__')
    log=path.read_text(encoding='utf-8',errors='replace') if path.is_file() else ''
    if not log: problems.append('Full local SAS log missing')
    runtime=re.search(r'^=== SAS Log ===\r?\n(.*?)(?:\r?\n=== Output ===|\Z)',log,re.M|re.S)
    runtime_log=runtime[1] if runtime else ''
    visible='\n'.join(line for line in runtime_log.splitlines() if not re.match(r'^\s*(?:\d+(?:\s+|!\s*)|MPRINT\([^)]*\):|SYMBOLGEN:|MLOGIC\([^)]*\):)',line,re.I))
    if not runtime_log.strip():problems.append('SAS runtime log missing')
    diagnostic_text=visible
    if case.get('fail'):
        if data.get('exit_code')!=1:problems.append('Infrastructure/worker failure cannot validate an intentional SAS error')
        diagnostic_text='\n'.join(line for line in visible.splitlines() if re.match(r'^\s*(?:ERROR|WARNING)(?:\s+\d+-\d+)?:',line,re.I))
        if not diagnostic_text:problems.append('Expected runtime SAS diagnostic absent')
    if case.get('diagnostic') and not re.search(case['diagnostic'],diagnostic_text,re.I): problems.append('Expected diagnostic absent')
    if case.get('forbid') and re.search(case['forbid'],log,re.I): problems.append('Forbidden dependency injected')
    if not case.get('fail') and not re.search(r'^MCP30_OK_'+re.escape(case['id'])+r'\s*$',runtime_log,re.M): problems.append('Computed result marker absent')
    diagnostics=data.get('diagnostics',{})
    for key,field in [('quality','data_quality_count'),('warning','warning_count')]:
        if case.get(key) and not diagnostics.get(field): problems.append(f'Expected {key} diagnostic absent')
        if batch>=5 and not case.get('fail') and not case.get(key) and diagnostics.get(field): problems.append(f'Unexpected {key} diagnostic')
    if not case.get('fail') and case.get('html',True):
        if not any(p.stat().st_size for p in path.parent.glob('*.html')): problems.append('Nonempty HTML missing')
    return dict(id=case['id'],name=case['name'],passed=not problems,problems=problems,
                status=data.get('status'),exit_code=data.get('exit_code'),log_path=str(path),diagnostics=diagnostics)

async def run(cases,args,out):
    results=[]
    session='python_examples_'+secrets.token_hex(8)
    async with client(out,args.url,args.legacy_http) as call:
        try:
            for case in cases:
                started_at=time.perf_counter()
                try:
                    started,done=await completed(call,dict(sas_codes_or_file=case['path'],session_id=session,
                        persistent=bool(case.get('persistent',True)),run_timeout_seconds=180),300)
                    save(out/f'{case["id"]}_started.json',started);save(out/f'{case["id"]}_response.json',done)
                    result=assess(case,done,args.batch)
                    if result['exit_code'] in (74,124):
                        session='python_recovery_'+secrets.token_hex(8)
                        result['next_session_refreshed']=True
                except Exception as exc:
                    result=dict(id=case['id'],name=case['name'],passed=False,problems=[str(exc)])
                    # Preserve failure and continue with new WORK; never replay it.
                    session='python_recovery_'+secrets.token_hex(8)
                result['elapsed_seconds']=round(time.perf_counter()-started_at,3)
                results.append(result);save(out/'results.json',results)
                print(f'{case["id"]} {case["name"]}: {"PASS" if result["passed"] else "FAIL"}',flush=True)
            fixtures=['~/'+Path(path).name for case in cases for path in case['fixture_paths']]
            if fixtures:
                _,done=await completed(call,dict(delete_file=fixtures,session_id=session),180)
                save(out/'fixture_cleanup.json',done)
                if done.get('isError'): raise RuntimeError('Remote fixture cleanup failed; see retained response')
        finally:
            _,done=await completed(call,dict(kill_saspy_sessions=True,session_id=session),60)
            save(out/'session_close.json',done)
    return 0 if results and all(r['passed'] for r in results) else 1

def main(argv=None):
    parser=argparse.ArgumentParser(description=__doc__)
    mode=parser.add_mutually_exclusive_group(required=True)
    mode.add_argument('--live',action='store_true');mode.add_argument('--generate-only',action='store_true')
    parser.add_argument('--batch',type=int,choices=range(1,9),default=1)
    parser.add_argument('--only',help='Comma-separated case IDs, e.g. 01,02')
    parser.add_argument('--out');parser.add_argument('--library-root');parser.add_argument('--url')
    parser.add_argument('--legacy-http',action='store_true',help='Use the Perl server bare JSON-RPC HTTP endpoint instead of SDK transport')
    args=parser.parse_args(argv)
    out=Path(args.out or ROOT/'MCP4SAS_Use_Python/test-results'/('examples_'+secrets.token_hex(6))).resolve()
    cases=generate(args.batch,out,args.library_root)
    if args.only:
        selected={str(int(v)).zfill(2) for v in args.only.split(',')}
        if selected-{c['id'] for c in cases}: parser.error('Unknown --only ID for this batch')
        cases=[c for c in cases if c['id'] in selected]
    print(f'Generated original batch {args.batch}: {len(cases)} selected cases; {out}',flush=True)
    if args.generate_only: return 0
    return asyncio.run(run(cases,args,out))
