"""Native SDK live tests of MCP status, archive bytes and diagnostic reporting."""
import argparse
import asyncio
import json
from pathlib import Path
import re
import secrets
from .live_examples import client,completed

ROOT=Path(__file__).resolve().parents[1]


async def run(out,diagnostics_only=False):
    session='mcp_reg_'+secrets.token_hex(8);tag=secrets.token_hex(8)
    records=[];fixtures=[]
    async with client(out) as call:
        async def check(label,arguments,expected=0,marker=None,diagnostic=None):
            initial,result=await completed(call,dict(arguments,session_id=session),240)
            (out/(label+'.json')).write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
            info=result.get('structuredContent',{});text='\n'.join(v.get('text','') for v in result.get('content',[]))
            problems=[]
            if info.get('exit_code')!=expected:problems.append(f"exit {info.get('exit_code')}, expected {expected}")
            if bool(result.get('isError'))!=(expected!=0):problems.append('MCP error flag inconsistent')
            if info.get('status')!=('COMPLETE' if expected==0 else 'FAILED'):problems.append('MCP terminal status inconsistent')
            if marker and not re.search('^'+re.escape(marker)+r'\s*$',text,re.M):problems.append('computed runtime marker absent')
            if diagnostic and not re.search(r'^\s*ERROR(?:\s+\d+-\d+)?:.*'+diagnostic,text,re.I|re.M):problems.append('runtime error absent')
            row=dict(label=label,passed=not problems,problems=problems,exit_code=info.get('exit_code'))
            records.append(row);(out/'execution.json').write_text(json.dumps(records,indent=2)+'\n')
            print(json.dumps(row),flush=True)
            if problems:raise AssertionError(row)
            return result
        try:
            if not diagnostics_only:
                await check('positive',dict(sas_codes_or_file='proc sql noprint;select count(*) into :known trimmed from sashelp.class;quit;%put PY_MCP_COUNT=&known;'),marker='PY_MCP_COUNT=19')
                await check('negative',dict(sas_codes_or_file='proc print data=work.py_mcp_missing;run;'),expected=1,diagnostic='PY_MCP_MISSING')
                for index in range(2):
                    file=out/f'fixture_{tag}_{index}.txt';file.write_bytes(b'archive roundtrip\n'+bytes([index]))
                    fixtures.append(file)
                await check('upload',dict(upload_file=[p.as_posix() for p in fixtures]))
                paths=[out/('received_'+p.name) for p in fixtures]
                await check('download',dict(download_file=['~/'+p.name for p in fixtures],download_local_path=[p.as_posix() for p in paths]))
                for source,target in zip(fixtures,paths):assert source.read_bytes()==target.read_bytes(),'archive roundtrip changed bytes'
                await check('missing_download',dict(download_file='~/missing_'+tag),expected=1)
            flow=await check('flowover',dict(sas_codes_or_file="options notes;filename pfile temp;data _null_;file pfile;put 'ab';run;data probe;infile pfile;input value $20.;run;proc print data=probe;run;filename pfile clear;"))
            assert flow['structuredContent']['diagnostics']['data_quality_count']>=2,'flowover and empty dataset diagnostics missing'
            await check('format_name',dict(sas_codes_or_file="proc format;value bad1 1='one';run;"),expected=1,diagnostic='format name BAD1 ends in a number')
        finally:
            if fixtures:await check('cleanup',dict(delete_file=['~/'+p.name for p in fixtures]))
            await check('close',dict(kill_saspy_sessions=True))
    return 0


def main(diagnostics_only=False):
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--live',action='store_true',required=True);p.add_argument('--out',type=Path)
    args=p.parse_args();out=(args.out or ROOT/'MCP4SAS_Use_Python/test-results'/('mcp_reg_'+secrets.token_hex(5))).resolve()
    out.mkdir(parents=True,exist_ok=False)
    return asyncio.run(run(out,diagnostics_only))
