#!/usr/bin/env python3
"""Native Python counterpart of run_live_library500.pl.

Runs the original hash-verified SAS programs and numerical oracles through the
public Python CLI; negatives execute alone, and only this test session is closed.
"""
import argparse
import json
import os
from pathlib import Path
import secrets
import subprocess
import sys
import time
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT))
from MCP4SAS_Use_Python.evaluation import select_cases,checked_source,contract_fingerprint,evaluate


def main(argv=None):
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--live',action='store_true',required=True)
    p.add_argument('--round',type=int,choices=(1,2,3,4,5,6,7,8,9,10),default=1)
    p.add_argument('--only');p.add_argument('--batch-size',type=int,default=100)
    p.add_argument('--out',type=Path)
    args=p.parse_args(argv)
    if not 1<=args.batch_size<=100:p.error('--batch-size must be 1..100')
    name='library500' if args.round==1 else 'macro_open_code50' if args.round==9 else 'library500_round'+str(args.round)
    directory=ROOT/'tests'/name
    cases=select_cases(json.loads((directory/'manifest.json').read_text(encoding='utf-8')),args.only)
    programs={case['id']:checked_source(case,(directory/case['file']).read_bytes().decode('utf-8')) for case in cases}
    output=(args.out or ROOT/'MCP4SAS_Use_Python/test-results'/('live_'+name+'_'+secrets.token_hex(4))).resolve()
    output.mkdir(parents=True,exist_ok=False)
    session='corpus_'+secrets.token_hex(10)
    env=dict(os.environ,OPEN_RESULT='0',SAS_ODA_AUTOLOAD_MACROS='0',PYTHONUNBUFFERED='1')
    marker='LIB500_PASS' if args.round==1 else 'ROUND'+str(args.round)+'_PASS'
    command=[sys.executable,(ROOT/'run_sas_codes_or_files_in_ODA.py').as_posix()]
    records=[];batches=[]
    try:
        while cases:
            group=[cases.pop(0)]
            if args.round!=9 and not group[0].get('expected_failure'):
                while cases and not cases[0].get('expected_failure') and len(group)<args.batch_size:group.append(cases.pop(0))
            label=group[0]['id']+'_'+group[-1]['id']
            file=output/(label+'.sas');file.write_text('options notes merror serror;\n'+'\n'.join(programs[c['id']] for c in group),encoding='utf-8')
            start=time.monotonic()
            proc=subprocess.run(command+(['--no-submission-preflight'] if args.round==9 else [])+['--file',file.as_posix(),'--persistent','--session-id',session,
                '--run-timeout-seconds','180','--output-prefix',(output/label).as_posix()],cwd=ROOT,env=env,capture_output=True,timeout=240)
            (output/(label+'.cli.log')).write_bytes(proc.stdout+proc.stderr)
            log_file=output/label/'output.html.info.txt';status_file=output/label/'output.html.run.status.json'
            report=log_file.read_text(encoding='utf-8') if log_file.is_file() else ''
            status=json.loads(status_file.read_text(encoding='utf-8')) if status_file.is_file() else None
            first=group[0]
            result=evaluate(report=report,marker=marker,expected=[c['id'] for c in group],exit_code=proc.returncode,
                expected_failure=first.get('expected_failure'),diagnostic=first.get('diagnostic'),
                policy_failure=first.get('policy_failure'),warning_pattern=first.get('warning_pattern'),status=status,require_status=True)
            for case in group:
                records.append(dict(id=case['id'],family=case['family'],passed=result['passes'][case['id']],
                    body_sha256=case['body_sha256'],contract_sha256=contract_fingerprint(case),batch=label,
                    expected_failure=bool(case.get('expected_failure'))))
            batches.append(dict(label=label,exit_code=proc.returncode,seconds=round(time.monotonic()-start,3),evaluation=result))
            (output/'results.json').write_text(json.dumps(dict(round=args.round,session=session,selected=len(records),results=records,batches=batches),indent=2)+'\n',encoding='utf-8')
            print(f'{label}: {sum(c["passed"] for c in records)}/{len(records)} passed',flush=True)
            if result['infrastructure_failure']:raise RuntimeError('Infrastructure failure; stopped instead of claiming a SAS oracle failure')
    finally:
        closed=subprocess.run(command+['--session-id',session,'--kill-saspy-sessions','--output-prefix',(output/'session_close').as_posix()],cwd=ROOT,env=env,capture_output=True,timeout=90)
        (output/'session_close.cli.log').write_bytes(closed.stdout+closed.stderr)
    return int(any(not c['passed'] for c in records) or closed.returncode!=0)


if __name__=='__main__':raise SystemExit(main())
