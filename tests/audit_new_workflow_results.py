"""Recheck saved SAS evidence and publish a compact, hash-linked test manifest."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import xml.etree.ElementTree as ET
from run_new_workflows import verify,ROOT

def sha(file):return hashlib.sha256(file.read_bytes()).hexdigest()
def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('runs',type=Path,nargs='+')
    p.add_argument('--output',type=Path,default=ROOT/'docs/NEW_WORKFLOW_EXECUTION_MANIFEST.json')
    args=p.parse_args();runs=[];failures=[]
    for directory in args.runs:
        directory=directory.resolve();result_file=directory/'results.json';run=json.loads(result_file.read_text())
        source=ROOT/'tests'/run['collection'];manifest=json.loads((source/'manifest.json').read_text())
        lookup={c['id']:c for c in manifest['cases']};cases=[];files=[]
        if len(run['cases'])!=500 or {c['id'] for c in run['cases']}!=set(lookup):failures.append(str(directory)+': incomplete selection')
        for c in run['cases']:
            expected=lookup[c['id']];file=directory/'tables'/(c['id']+'.csv')
            issues,checks=verify(expected,file)
            if not c['passed'] or c['source_sha256']!=expected['sha256']:issues.append('Original source/result status mismatch')
            if issues:failures.append(dict(run=directory.name,id=c['id'],issues=issues))
            cases.append(dict(id=c['id'],family=c['family'],verified=not issues,metrics=checks,
                source_sha256=expected['sha256'],csv_sha256=sha(file) if file.is_file() else None))
            for name in expected.get('assets',[]):
                graphic=directory/'tables'/name
                try:
                    root=ET.parse(graphic).getroot();assert root.tag.endswith('svg')
                    files.append(dict(file=graphic.relative_to(ROOT).as_posix(),sha256=sha(graphic)))
                except (OSError,ET.ParseError,AssertionError):failures.append(str(graphic)+': invalid SVG')
        batches=[];warnings=Counter()
        for batch in run['batches']:
            label=batch['label'];log_file=directory/label/'output.html.info.txt';log=log_file.read_text(encoding='utf-8',errors='replace')
            if batch['exit_code'] or batch['errors'] or not batch['status'].get('success'):failures.append(label+': non-success execution')
            for c in run['cases']:
                if c['batch']==label and len(re.findall(r'^NEW_WORKFLOW_DONE='+c['id']+r'\s*$',log,re.M))!=1:failures.append(c['id']+': invalid actual runtime marker')
            for warning in batch['warnings']:warnings[warning]+=1
            batches.append(dict(label=label,submit_seconds=batch['submit_seconds'],download_seconds=batch['download_seconds'],
                input_sha256=sha(directory/(label+'.sas')),log_sha256=sha(log_file),sas_errors=len(batch['errors']),warning_count=len(batch['warnings'])))
        for operation in ('owned_upload_cleanup','session_close'):
            target=directory/operation
            status_file=target/('output.html.run.status.json' if run['runtime']=='python' else 'output.run.status.json')
            if status_file.is_file():
                status=json.loads(status_file.read_text())
                if not status.get('success') or not status.get('complete'):failures.append(directory.name+': '+operation+' failed')
        runs.append(dict(directory=directory.relative_to(ROOT).as_posix(),collection=run['collection'],runtime=run['runtime'],
            cases=len(cases),verified=sum(c['verified'] for c in cases),metrics=sum(c['metrics'] for c in cases),
            submissions=len(batches),results_sha256=sha(result_file),manifest_sha256=sha(source/'manifest.json'),
            elapsed_seconds=run['elapsed_seconds'],warnings=dict(warnings),batches=batches,case_results=cases,svg_assets=files))
    report=dict(schema=1,scope='1000 unique synthetic workflows; each executed via both independent runners on SAS ODA. Not 1000 distinct source programs or connections.',
        runs=runs,failures=failures)
    args.output.write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(json.dumps(dict(runs=len(runs),evaluations=sum(r['cases'] for r in runs),verified=sum(r['verified'] for r in runs),failures=failures)))
    return bool(failures)

if __name__=='__main__':raise SystemExit(main())
