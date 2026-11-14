"""Opt-in live SAS submission/recovery through the actual Python MCP server."""
import argparse
import asyncio
import json
import os
from pathlib import Path
import re
import sys
import time

ROOT=Path(__file__).resolve().parents[2]

async def run(out):
    from mcp import ClientSession,StdioServerParameters
    from mcp.client.stdio import stdio_client
    out.mkdir(parents=True,exist_ok=False)
    records=[]
    env=dict(os.environ,OPEN_RESULT='0')
    params=StdioServerParameters(command=sys.executable,args=[str(ROOT/'server.py')],cwd=str(out),env=env)
    async with stdio_client(params) as (read,write):
        async with ClientSession(read,write) as session:
            await session.initialize()
            for name,code,expected,marker in [
                ('positive','proc sql noprint; select count(*) into :py_n trimmed from sashelp.class;quit;%put MCP_PYTHON_COUNT=&py_n;',0,'MCP_PYTHON_COUNT=19'),
                ('negative','proc print data=work.__mcp_python_absent__;run;',1,None),
            ]:
                start=time.perf_counter()
                initial=await session.call_tool('run_sas_codes_or_files_in_ODA',dict(sas_codes_or_file=code,persistent=False,saspy_cfgname='oda',run_timeout_seconds=120))
                if initial.isError:
                    raise AssertionError(initial)
                pid=initial.structuredContent['pid']
                deadline=time.monotonic()+180
                while True:
                    done=await session.call_tool('run_sas_codes_or_files_in_ODA',dict(pid=pid))
                    if done.structuredContent['status']!='RUNNING':
                        break
                    if time.monotonic()>deadline:
                        raise TimeoutError('MCP job did not finish')
                    await asyncio.sleep(1)
                if done.structuredContent.get('exit_code')!=expected or done.isError!=(expected!=0):
                    raise AssertionError(done)
                text=done.content[0].text
                if marker and not re.search(r'^'+re.escape(marker)+r'\s*$',text,re.M):
                    raise AssertionError('Missing known runtime marker')
                record=dict(case=name,status=done.structuredContent['status'],exit_code=done.structuredContent['exit_code'],isError=done.isError,seconds=round(time.perf_counter()-start,3),marker=marker)
                records.append(record)
                (out/(name+'.json')).write_text(done.model_dump_json(indent=2),encoding='utf-8')
                print(json.dumps(record),flush=True)
    (out/'execution.json').write_text(json.dumps(dict(transport='actual MCP stdio',runtime='native Python',cases=records),indent=2),encoding='utf-8')

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--outdir',required=True)
    args=parser.parse_args()
    asyncio.run(run(Path(args.outdir).resolve()))

if __name__=='__main__':
    main()
