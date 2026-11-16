"""Beta macro wiring regression. Offline by default; --live opts into actual SAS.

Use --runner python|perl|both and explicit --saspy-cfgname/--saspy-cfgfile.
Synthetic examples validate software behavior, not research-model calibration.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import time

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT))
from MCP4SAS_Use_Python.dependencies import Plan

EXPECTED={'renamed_predictor_compare','custom_output_has_four_parameters',
          'one_prediction_per_input_row','nlmixed_converged',
          'requested_output_preserves_default_table','initializer_macro_variable_preserved'}


def main(argv=None):
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--live',action='store_true')
    parser.add_argument('--guards',action='store_true',help='Also execute four expected-failure input-validation cases.')
    parser.add_argument('--runner',choices=('python','perl','both'),default='python')
    parser.add_argument('--perl',default=shutil.which('perl'))
    parser.add_argument('--saspy-cfgname',default='oda')
    parser.add_argument('--saspy-cfgfile')
    parser.add_argument('--out',type=Path)
    args=parser.parse_args(argv)
    macro=ROOT/'examples/sas_macros/scASE_betabino.sas'
    source=ROOT/'tests/beta_macro_regression.sas'
    text=macro.read_text(encoding='utf-8')
    assert re.search(r'tot_var=tot\s*,\s*outdsd=',text)
    assert '&model_vars' not in text and '&modelvars' not in text
    assert 'b1*&model_var+u' in text
    assert 'ParameterEstimates=&outdsd' in text
    old=Path.cwd();os.chdir(ROOT)
    try:plan=Plan(source.read_text(),source)
    finally:os.chdir(old)
    assert macro.resolve() in plan.texts
    assert not plan.analysis['findings'],plan.analysis['findings']
    print('PASS: corrected Beta parameter wiring and offline dependency plan',flush=True)
    if not args.live:
        print('LIVE SAS FITS NOT RUN: pass --live to execute the synthetic model regression.')
        return 0
    out=args.out or ROOT/('SAS_Output_beta_regression_'+str(time.time_ns()))
    out.mkdir(parents=True,exist_ok=False)
    records=[]
    for runtime in (('python','perl') if args.runner=='both' else (args.runner,)):
        interpreter=sys.executable if runtime=='python' else args.perl
        if not interpreter:raise ValueError('Supply --perl for the Perl regression')
        folder=out/runtime
        command=[interpreter,(ROOT/('run_sas_codes_or_files_in_ODA.'+('py' if runtime=='python' else 'pl'))).as_posix(),
                 '--file',source.as_posix(),'--output-prefix',folder.as_posix(),
                 '--saspy-cfgname',args.saspy_cfgname,'--skip-sas-oda-auth-bootstrap',
                 '--no-open-html','--run-timeout-seconds','180']
        if args.saspy_cfgfile:command+=['--saspy-cfgfile',str(Path(args.saspy_cfgfile).resolve())]
        env=dict(os.environ,OPEN_RESULT='0',SAS_ODA_AUTOLOAD_MACROS='0',PIPELINE_PYTHON_BIN=Path(sys.executable).as_posix())
        started=time.monotonic()
        with (out/(runtime+'.stdout.txt')).open('w',encoding='utf-8') as stdout,(out/(runtime+'.stderr.txt')).open('w',encoding='utf-8') as stderr:
            result=subprocess.run(command,cwd=ROOT,env=env,stdout=stdout,stderr=stderr,timeout=240)
        log=(folder/'output.html.info.txt').read_text(encoding='utf-8',errors='replace')
        passed=set(re.findall(r'^BETA_TEST_PASS=(\w+)\s*$',log,re.M))
        errors=re.findall(r'^\s*ERROR[^\r\n]*',log,re.M)
        warnings=re.findall(r'^\s*WARNING[^\r\n]*',log,re.M)
        record=dict(runtime=runtime,target=args.saspy_cfgname,exit_code=result.returncode,
                    seconds=round(time.monotonic()-started,3),passed=sorted(passed),expected=sorted(EXPECTED),
                    errors=errors,warnings=warnings,success=result.returncode==0 and passed==EXPECTED and not errors,
                    macro_sha256=hashlib.sha256(macro.read_bytes()).hexdigest(),source_sha256=hashlib.sha256(source.read_bytes()).hexdigest())
        records.append(record);(out/'execution.json').write_text(json.dumps(records,indent=2)+'\n',encoding='utf-8')
        print(json.dumps(record),flush=True)
        if args.guards:
            for case,diagnostic in [('missing_input','SCASE_MISSING_INPUT'),
                                    ('invalid_counts','SCASE_INVALID_COUNTS'),
                                    ('missing_predictor','SCASE_MISSING_VARIABLE'),
                                    ('output_overlap','SCASE_OUTPUT_OVERLAPS_INPUT')]:
                submitted=out/(runtime+'-'+case+'.sas')
                submitted.write_text('%let beta_invalid_case='+case+';\n%include "tests/beta_macro_invalid_inputs.sas";\n',encoding='utf-8')
                target=out/(runtime+'-'+case)
                guard_command=list(command)
                guard_command[guard_command.index('--file')+1]=submitted.as_posix()
                guard_command[guard_command.index('--output-prefix')+1]=target.as_posix()
                start=time.monotonic()
                with (out/(runtime+'-'+case+'.stdout.txt')).open('w',encoding='utf-8') as stdout,(out/(runtime+'-'+case+'.stderr.txt')).open('w',encoding='utf-8') as stderr:
                    result=subprocess.run(guard_command,cwd=ROOT,env=env,stdout=stdout,stderr=stderr,timeout=240)
                log=(target/'output.html.info.txt').read_text(encoding='utf-8',errors='replace')
                errors=re.findall(r'^\s*ERROR[^\r\n]*',log,re.M)
                marker=bool(re.search(r'^BETA_GUARD_PASS='+re.escape(case)+r'\s*$',log,re.M))
                success=result.returncode==1 and marker and len(errors)==1 and diagnostic in errors[0]
                guard=dict(runtime=runtime,target=args.saspy_cfgname,case=case,exit_code=result.returncode,
                           expected_exit_code=1,expected_diagnostic=diagnostic,postcondition_passed=marker,
                           seconds=round(time.monotonic()-start,3),errors=errors,success=success)
                records.append(guard)
                (out/'execution.json').write_text(json.dumps(records,indent=2)+'\n',encoding='utf-8')
                print(json.dumps(guard),flush=True)
    return 0 if all(r['success'] for r in records) else 1


if __name__=='__main__':raise SystemExit(main())
