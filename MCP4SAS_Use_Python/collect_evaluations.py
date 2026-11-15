"""Re-evaluate saved SAS evidence, never trusting recorded pass booleans."""
import argparse
import json
from pathlib import Path
import re
from .evaluation import (select_cases,checked_source,checked_contract,contract_fingerprint,
                         normalized,evaluate)

ROOT=Path(__file__).resolve().parents[1]


def collect(round_number,runs,skip_stale=False):
    if round_number not in (1,2,3,4,5,6,7,8,9,10):raise ValueError('Invalid round')
    directory=ROOT/'tests'/('library500' if round_number==1 else 'macro_open_code50' if round_number==9 else 'library500_round'+str(round_number))
    cases=select_cases(json.loads((directory/'manifest.json').read_text(encoding='utf-8')))
    known={v['id']:v for v in cases}
    programs={v['id']:checked_source(v,(directory/v['file']).read_text(encoding='utf-8')) for v in cases}
    chosen={};attempts=[];stale=[]
    for value in runs:
        run=Path(value).resolve(strict=True)
        allowed=(run.parent==ROOT and re.fullmatch(r'SAS_Output_library500_live_[A-Za-z0-9_]+',run.name)) or run.is_relative_to(ROOT/'MCP4SAS_Use_Python/test-results')
        if not allowed:raise ValueError('Run outside evaluation workspace')
        data=json.loads((run/'results.json').read_text(encoding='utf-8'))
        if data.get('round')!=round_number:raise ValueError('Wrong round')
        batches={b['label']:b for b in data['batches']};groups={}
        for result in data['results']:
            if result['id'] not in known:raise ValueError('Unknown ID '+result['id'])
            groups.setdefault(result['batch'],[]).append(result)
        for label,group in groups.items():
            if not re.fullmatch(r'[A-Z]\d{3,4}_[A-Z]\d{3,4}',label):raise ValueError('Invalid batch label')
            changed=any(v.get('body_sha256')!=known[v['id']]['body_sha256'] or
                        (v.get('contract_sha256') is not None and v['contract_sha256']!=contract_fingerprint(known[v['id']])) for v in group)
            if changed and skip_stale:
                stale.extend(dict(id=v['id'],batch=label,source_run=str(run),reason='Changed source or oracle; excluded') for v in group)
                continue
            for v in group:
                if v.get('body_sha256')!=known[v['id']]['body_sha256']:raise ValueError('Body hash mismatch '+v['id'])
                verified=checked_contract(known[v['id']],v.get('contract_sha256'))
                if round_number>=8 and not verified:raise ValueError('Missing evaluation contract '+v['id'])
            batch=batches[label]
            # Both documented harness headers are accepted; arbitrary additions,
            # changed constants, and reordered case bodies are rejected.
            source=normalized((run/(label+'.sas')).read_text(encoding='utf-8'))
            body='\n'.join(programs[v['id']] for v in group)
            if source not in [normalized(header+body) for header in ('options notes;\n','options notes merror serror;\n')]:
                raise ValueError('Submitted source mismatch '+label)
            status_path=run/label/'output.html.run.status.json'
            if not status_path.is_file():status_path=run/label/'output.run.status.json'
            status=json.loads(status_path.read_text(encoding='utf-8'))
            report=(run/label/'output.html.info.txt').read_text(encoding='utf-8')
            evaluations={}
            for record in group:
                case=known[record['id']]
                key=(bool(case.get('expected_failure')),case.get('diagnostic'),case.get('warning_pattern'),bool(case.get('policy_failure')))
                if key not in evaluations:
                    evaluations[key]=evaluate(report=report,marker='LIB500_PASS' if round_number==1 else 'ROUND'+str(round_number)+'_PASS',
                        expected=[v['id'] for v in group],exit_code=batch['exit_code'],expected_failure=case.get('expected_failure'),
                        diagnostic=case.get('diagnostic'),warning_pattern=case.get('warning_pattern'),policy_failure=case.get('policy_failure'),
                        status=status,require_status=True)
                result=evaluations[key]
                attempt=dict(id=case['id'],source_run=str(run),batch=label,passed=result['passes'][case['id']],
                    recorded_pass=record.get('passed',record.get('pass')),contract_sha256=record.get('contract_sha256'),
                    body_sha256=case['body_sha256'],infrastructure_failure=result['infrastructure_failure'])
                attempts.append(attempt)
                if attempt['passed']:chosen[case['id']]=attempt
    return dict(schema=2,round=round_number,selected=len(cases),verified=len(chosen),
                results=[chosen.get(c['id'],dict(id=c['id'],passed=False)) for c in cases],
                attempts=attempts,stale_attempts=stale)


def main(argv=None):
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--round',type=int,required=True)
    p.add_argument('--run',action='append',required=True);p.add_argument('--output',type=Path,required=True)
    p.add_argument('--skip-stale',action='store_true');args=p.parse_args(argv)
    report=collect(args.round,args.run,args.skip_stale)
    args.output.write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(f"Verified {report['verified']}/{report['selected']} current contracts from saved runtime evidence")
    return 0 if report['verified']==report['selected'] else 1
