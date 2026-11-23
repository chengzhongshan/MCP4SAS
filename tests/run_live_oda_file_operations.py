"""Opt-in live regression for combined Python upload/download/delete/inspection.

Requires a privately configured SASPy ODA profile. Deletes only uniquely named
test inputs and exact paths from the selected earlier acceptance run.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import secrets
import subprocess
import sys
import time


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--live', action='store_true', required=True)
    parser.add_argument('--repo-root', type=Path, required=True)
    parser.add_argument('--acceptance-dir', type=Path)
    parser.add_argument('--out', type=Path, required=True)
    args=parser.parse_args()
    root=args.repo_root.resolve();out=args.out.resolve();out.mkdir(exist_ok=False,parents=True)
    token='oda_fileops_'+secrets.token_hex(6)
    env=dict(os.environ,OPEN_RESULT='0',SASPY_CFGNAME='oda',MCP4SAS_PYTHON_STATE_DIR=str(out/'backend-state'))
    script=root/'run_sas_codes_or_files_in_ODA.py'
    common=[sys.executable,str(script),'--saspy-cfgname','oda','--no-open-html','--run-timeout-seconds','180']
    old=[]
    if args.acceptance_dir:
        acceptance=json.loads((args.acceptance_dir/'acceptance.json').read_text())
        record=next(x for x in acceptance['runners'] if x['language']=='python')
        original=json.loads(next((args.acceptance_dir/'python').glob('*_cleanup_inputs/result.json')).read_text())
        assert all(x['exit_code']==0 for x in record['stages'])
        old=list(original['file_info'])
        assert all(p.startswith('~/'+record['session']) or p=='~/include_debug_'+record['session']+'_nested_macro.log' for p in old)
    local=[]
    for index in range(3):
        path=out/(token+f'_{index}.txt');path.write_text('owned ODA regression '+str(index)+'\n');local.append(path)
    removed=old+['~/'+p.name for p in local[:2]];keep='~/'+local[2].name
    details=[]
    def run(name,options):
        start=time.monotonic();folder=out/name
        result=subprocess.run(common+['--output-prefix',str(folder),*options],cwd=root,env=env,capture_output=True,timeout=210)
        (out/(name+'.console.log')).write_bytes(result.stdout+b'\n'+result.stderr)
        details.append(dict(stage=name,exit_code=result.returncode,seconds=round(time.monotonic()-start,3)))
        assert result.returncode==0,(name,result.returncode)
        return json.loads((folder/'result.json').read_text())
    succeeded=False
    try:
        options=[]
        for path in local:options+=['--upload-file',str(path)]
        options+=['--download-file','~/'+local[0].name,'--download-local-path',str(out/'returned.txt')]
        for remote in removed:options+=['--delete-file',remote,'--file-info',remote]
        options+=['--dir4listing','~','--file-info',keep]
        result=run('combined',options)
        assert hashlib.sha256(local[0].read_bytes()).digest()==hashlib.sha256((out/'returned.txt').read_bytes()).digest()
        assert len(result['deleted'])==len(removed)
        assert all(result['file_info'][p]['exists'] is False for p in removed)
        assert result['file_info'][keep]['exists'] is True
        assert local[2].name in result['files'] and all(Path(p).name not in result['files'] for p in removed)
        succeeded=True
    finally:
        cleanup=[]
        for path in local:cleanup+=['--delete-file','~/'+path.name,'--file-info','~/'+path.name]
        result=run('cleanup',cleanup)
        assert all(v['exists'] is False for v in result['file_info'].values())
    summary=dict(passed=succeeded,repo=str(root),target='oda',stages=details,
                 prior_inputs_verified_absent=len(old),new_files=3,download_sha256_matches=True,
                 final_listing_and_metadata_correct=True,unselected_file_preserved=True,
                 unique_remote_inputs=len(old)+3,all_test_inputs_verified_absent=True,
                 source_sha256=hashlib.sha256((root/'MCP4SAS_Use_Python/cli.py').read_bytes()).hexdigest())
    (out/'followup.json').write_text(json.dumps(summary,indent=2)+'\n')
    if args.acceptance_dir:
        (args.acceptance_dir/'cleanup_resolution.json').write_text(json.dumps(dict(summary,evidence=str(out/'followup.json')),indent=2)+'\n')
    print(json.dumps(summary))


if __name__=='__main__':main()
