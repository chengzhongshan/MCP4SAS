"""Maintainer-only: summarize private execution evidence without account data."""
import hashlib
import importlib.metadata
import json
from pathlib import Path
import platform
import subprocess
import sys

HERE=Path(__file__).resolve().parents[1]
ROOT=HERE.parent

def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()

def main():
    observed=json.loads((HERE/'test-results/oda-native-python-v3/execution.json').read_text(encoding='utf-8'))
    cases=[]
    for item in observed['cases']:
        row={key:item[key] for key in ('case','exit_code','expected_exit','seconds','marker','warning_count','source_sha256') if key in item}
        if 'validation' in item:
            row['checks']=item['validation']['checks']
            row['warning_lines']=item['validation']['warnings']
        cases.append(row)
    examples=json.loads((ROOT/'examples/poc/manifest.json').read_text(encoding='utf-8'))['cases']
    artifacts=[]
    for case in examples:
        directory=HERE/'test-results/oda-native-python-v3'/('poc_'+case['id'])
        for name in case['files']:
            file=directory/'files'/name
            artifacts.append(dict(case=case['id'],name=name,bytes=file.stat().st_size,sha256=digest(file)))
        for kind,path in [('program',case['program'])]+[('input',item['file']) for item in case['inputs']]:
            file=ROOT/'examples/poc'/path
            artifacts.append(dict(case=case['id'],kind=kind,name='examples/poc/'+path,bytes=file.stat().st_size,sha256=digest(file)))
    live_mcp=json.loads((HERE/'test-results/live-mcp/execution.json').read_text(encoding='utf-8'))
    local=json.loads((HERE/'test-results/local-com/result.json').read_text(encoding='utf-8'))
    local_known='PYTHON_LOCAL_CLASS=19 MIN=11 MAX=16' in local['log']
    direct=(HERE/'test-results/direct-local/output.html.info.txt').read_text(encoding='utf-8')
    profile_before=json.loads((HERE/'test-results/python-source-profile.json').read_text())['files'][0]['measurements']
    profile_after=json.loads((HERE/'test-results/python-source-profile-optimized.json').read_text())['files'][0]['measurements']
    hashes_match=all(a['result_sha256']==b['result_sha256'] for a,b in zip(profile_before,profile_after))
    manifest=dict(manifest_generated_from_commit=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),baseline='796c37b39e5c3017493de227b244413f8e684141',platform=platform.system(),python=platform.python_version(),dependencies={name:importlib.metadata.version(name) for name in ('mcp','saspy','Pillow')},scope='Runtime and utility port; not complete scientific validation, model benchmark or full research-pipeline rerun',offline_tests=30,original_perl_reference_comparisons=308,shared_analysis_reference_comparisons=220,diagnostic_reference_logs=5,exact_cleanup_reference_programs=2,oda_cases=cases,poc_checks=sum(item.get('checks',0) for item in cases),live_mcp=live_mcp,local_windows_com=dict(exit_code=local['exit_code'],known_values_match=local_known,diagnostics=local['diagnostics']),direct_local_sas=dict(known_count_present='PYTHON_DIRECT_LOCAL_COUNT=19' in direct),large_source_profile=dict(source_bytes=816114,result_hashes_unchanged=hashes_match,note='One local observation per operation; not a cross-runtime benchmark',operations=[dict(operation=a['operation'],before_seconds=a['median_seconds'],after_seconds=b['median_seconds'],result_sha256=b['result_sha256']) for a,b in zip(profile_before,profile_after)]),artifacts=artifacts,limitations=['Original SAS graphics/recursive-table warnings retained','No live SAS execution on macOS/Linux','Developer-only corpus/test ports deferred','Existing VS Code extension remains on Perl','No token/cost/paired speed experiment'])
    (HERE/'VALIDATION_MANIFEST.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(dict(poc_checks=manifest['poc_checks'],artifacts=len(artifacts),local_com_ok=local_known,profile_result_hashes_match=hashes_match)))

if __name__=='__main__':
    main()
