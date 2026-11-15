#!/usr/bin/env python3
"""Independently recheck retained numerical and MCP catalog evidence.

This reads only repository-owned output directories. Failed original attempts
remain in the audit; an explicit successful rerun is a separate attempt.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT))
from MCP4SAS_Use_Python.collect_evaluations import collect
from MCP4SAS_Use_Python.demo_catalogs import catalog
from MCP4SAS_Use_Python.live_examples import assess

BASE=ROOT/'MCP4SAS_Use_Python/test-results'


def native(value):
    value=re.sub(r'^/(?:mnt|cygdrive)/([A-Za-z])/',lambda m:m[1].upper()+':/',str(value)) if sys.platform=='win32' else str(value)
    path=Path(value).resolve()
    if not path.is_relative_to(ROOT):raise ValueError('Evidence path outside repository: '+str(path))
    return path


def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()


def inspect_catalog(run,batch):
    cases={v['id']:v for v in catalog(batch)}
    metadata={v['id']:v for v in json.loads((run/'catalog.json').read_text(encoding='utf-8'))}
    rows=json.loads((run/'results.json').read_text(encoding='utf-8'));attempts=[]
    for row in rows:
        key=row['id'];blueprint=cases[key];case=metadata[key]
        source=blueprint['sas']
        paths=case.get('fixture_paths') or ([case['fixture_path']] if case.get('fixture_path') else [])
        for number,path in enumerate(paths,1):
            token='@FIXTURE_'+str(number)+'@' if blueprint.get('fixtures') else '@FIXTURE@'
            # Native Windows catalog metadata stores filesystem paths, whereas
            # its generated SAS program deliberately uses forward slashes.
            source=source.replace(token,str(path).replace('\\','/') if sys.platform=='win32' else path)
        problems=[]
        if source!=case['sas']:problems.append('SAS body differs from the original catalog')
        program=native(case['path'])
        submitted=program.read_text(encoding='utf-8')
        if submitted!='options notes nosyntaxcheck obs=max; ods select all; title; footnote;\n'+source:
            problems.append('Submitted SAS file differs from saved catalog body')
        response=json.loads((run/(key+'_response.json')).read_text(encoding='utf-8'))
        data=response.get('structuredContent',{})
        # The old HTTP server reports the directory separately; adapt the file
        # location only for local rechecking, without changing its saved reply.
        log=native(data.get('log_path') or str(native(row['directory'])/'output.html.info.txt'))
        response=dict(response,structuredContent=dict(data,log_path=str(log)))
        checked=assess(blueprint,response,batch)
        problems+=checked['problems']
        status_path=log.parent/'output.html.run.status.json'
        if not status_path.is_file():status_path=log.parent/'output.run.status.json'
        status=json.loads(status_path.read_text(encoding='utf-8'))
        wanted=bool(blueprint.get('fail'))
        if not status.get('complete') or bool(status.get('success'))==wanted:
            problems.append('Inconsistent terminal status')
        if data.get('exit_code') in (73,74,124):problems.append('Infrastructure failure is not a passing example')
        fields=('fail','diagnostic','forbid','quality','warning','persistent','html')
        current_contract={k:blueprint[k] for k in fields if k in blueprint}
        recorded_contract={k:case[k] for k in fields if k in case}
        if current_contract!=recorded_contract:
            problems.append('Recorded oracle differs; requires an explicit new run')
        # Source and diagnostic expectations are deliberately separate. Case
        # 240's first attempt retains its earlier expectation and its note.
        attempts.append(dict(id=key,batch=batch,passed=not problems,problems=problems,
            originally_passed=bool(row.get('passed')),oracle_changed=current_contract!=recorded_contract,
            source_run=run.relative_to(ROOT).as_posix(),source_sha256=digest(program),log_sha256=digest(log),
            status_sha256=digest(status_path),response_sha256=digest(run/(key+'_response.json'))))
    return attempts


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--output',type=Path,required=True)
    p.add_argument('--allow-incomplete',action='store_true');args=p.parse_args()
    report=dict(audit_source_commit=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),
                source_version_note='Runs span the test branch. Exact SAS bodies, oracle hashes and artifact digests are checked. The audit revision does not imply that every submission used this final Git revision.',
                numerical={},catalogs={},scope='Regression execution, not full scientific or publication validation')
    for runtime in ('python','perl'):
        results=[]
        for number in range(1,11):
            if runtime=='python':
                run=BASE/'python-live-library-round1' if number==1 else BASE/'python-all-collections'/('round'+str(number))
            else:
                index=27 if number==9 else 18 if number==1 else 26 if number==10 else 17+number
                name=f'{index:02d}_'+('run_live_macro_open_code50' if number==9 else 'run_live_library500_'+str(number))+'.log'
                text=(BASE/'remaining-live'/name).read_text(encoding='utf-8')
                match=re.search(r'Artifacts:\s+([^\r\n]+)',text)
                if not match:raise ValueError('No artifacts path in '+name)
                run=native(match[1].strip())
            if not (run/'results.json').is_file():continue
            audit=collect(number,[run])
            results.append(dict(round=number,selected=audit['selected'],verified=audit['verified'],
                run=run.relative_to(ROOT).as_posix(),results_sha256=digest(run/'results.json')))
        report['numerical'][runtime]=dict(selected=sum(v['selected'] for v in results),verified=sum(v['verified'] for v in results),rounds=results)
        attempts=[]
        parent=BASE/('catalogs-'+runtime+'-live')
        for batch in range(1,9):
            run=parent/('batch'+str(batch))
            if (run/'results.json').is_file():attempts+=inspect_catalog(run,batch)
        extras=[(BASE/'catalog5-reviewed-rerun',5)] if runtime=='python' else [(BASE/'catalog-perl-case26-rerun/batch1',1),(BASE/'catalog-perl-case129-rerun/batch4',4),(BASE/'catalog-perl-case240-rerun/batch5',5)]
        for run,batch in extras:
            if (run/'results.json').is_file():attempts+=inspect_catalog(run,batch)
        verified={v['id'] for v in attempts if v['passed']}
        expected={v['id'] for batch in range(1,9) for v in catalog(batch)}
        report['catalogs'][runtime]=dict(selected=590,verified=len(verified),missing=sorted(expected-verified,key=int),
            failed_attempts=[v for v in attempts if not v['passed']],attempts=attempts)
    report['complete']=all(v['verified']==4550 for v in report['numerical'].values()) and all(v['verified']==590 for v in report['catalogs'].values())
    args.output.parent.mkdir(parents=True,exist_ok=True)
    args.output.write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(dict(complete=report['complete'],numerical={k:v['verified'] for k,v in report['numerical'].items()},catalogs={k:v['verified'] for k,v in report['catalogs'].items()})))
    return 0 if report['complete'] or args.allow_incomplete else 1


if __name__=='__main__':raise SystemExit(main())
