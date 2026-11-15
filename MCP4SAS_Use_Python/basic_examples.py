"""Explicit live CLI checks for the repository's original beginner examples."""
import argparse
import json
import os
from pathlib import Path
import secrets
import subprocess
import sys
from .demo_catalogs import ROOT

CASES=['basic_summary','macro_control_flow','expected_missing_table','gtex_eqtl']

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--live',action='store_true',required=True)
    parser.add_argument('--only',nargs='+',choices=CASES,default=CASES)
    parser.add_argument('--out')
    args=parser.parse_args()
    out=Path(args.out or ROOT/'MCP4SAS_Use_Python/test-results'/('basic_'+secrets.token_hex(6))).resolve()
    out.mkdir(parents=True,exist_ok=False)
    results=[]
    for case in args.only:
        directory=out/case
        directory.mkdir()
        with (directory/'runner.log').open('w',encoding='utf-8') as stream:
            result=subprocess.run([sys.executable,str(ROOT/'run_sas_codes_or_files_in_ODA.py'),
                '--file',str(ROOT/f'examples/{case}.sas'),'--output-prefix',str(directory/'result'),
                '--run-timeout-seconds','180'],stdout=stream,stderr=subprocess.STDOUT,
                env=dict(os.environ,OPEN_RESULT='0',SAS_ODA_AUTOLOAD_MACROS='0'),cwd=ROOT)
        expected=1 if case=='expected_missing_table' else 0
        status_path=directory/'result/output.html.run.status.json'
        log_path=directory/'result/output.html.info.txt'
        status=json.loads(status_path.read_text(encoding='utf-8')) if status_path.exists() else {}
        log=log_path.read_text(encoding='utf-8') if log_path.exists() else ''
        problems=[]
        if result.returncode!=expected: problems.append('Unexpected exit status')
        if status.get('success')!=(expected==0): problems.append('Missing/inconsistent status JSON')
        if not log: problems.append('Full SAS log missing')
        if expected and 'WORK.MCP4SAS_MISSING_TABLE.DATA' not in log: problems.append('Expected SAS failure absent')
        if not expected:
            html=directory/'result/output.html'
            if not html.is_file() or not html.stat().st_size: problems.append('HTML missing')
            elif case=='gtex_eqtl' and 'APOBEC3A' not in html.read_text(encoding='utf-8'): problems.append('GTEx gene absent')
        record=dict(case=case,passed=not problems,exit_code=result.returncode,problems=problems)
        results.append(record)
        (out/'results.json').write_text(json.dumps(results,indent=2)+'\n',encoding='utf-8')
        print(json.dumps(record),flush=True)
    return 0 if all(item['passed'] for item in results) else 1
