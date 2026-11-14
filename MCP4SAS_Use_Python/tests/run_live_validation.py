"""Opt-in integration checks. Uses configured SAS credentials, never prints them.

Not discovered by unittest. Complete submitted code/logs remain in --outdir.
"""
import argparse
import csv
from datetime import datetime,timezone
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import time

ROOT=Path(__file__).resolve().parents[2]

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--outdir',required=True)
    parser.add_argument('--figures',action='store_true')
    parser.add_argument('--saspy-cfgname',default='oda')
    parser.add_argument('--saspy-cfgfile')
    args=parser.parse_args()
    out=Path(args.outdir).resolve()
    out.mkdir(parents=True,exist_ok=False)
    session='pyport_'+str(os.getpid())
    common=[sys.executable,str(ROOT/'run_sas_codes_or_files_in_ODA.py'),'--session-id',session,'--persistent','--saspy-cfgname',args.saspy_cfgname,'--run-timeout-seconds','120']
    if args.saspy_cfgfile:
        common+=['--saspy-cfgfile',args.saspy_cfgfile]
    env=dict(os.environ,OPEN_RESULT='0',SAS_ODA_AUTOLOAD_MACROS='0')
    records=[]
    def run(name,extra,expected=0,marker=None):
        target=out/name
        command=common+['--output-prefix',str(target)]+extra
        start=time.perf_counter()
        result=subprocess.run(command,cwd=ROOT,env=env,capture_output=True,timeout=180)
        target.mkdir(exist_ok=True)
        (target/'console.txt').write_bytes(result.stdout+result.stderr)
        seconds=round(time.perf_counter()-start,3)
        if result.returncode!=expected:
            raise AssertionError(f'{name}: expected exit {expected}, got {result.returncode}; inspect {target}')
        value=json.loads((target/'result.json').read_text(encoding='utf-8'))
        if marker and not re.search(r'^'+re.escape(marker)+r'\s*$',value['log'],re.M):
            raise AssertionError(f'{name}: missing runtime marker {marker}')
        record=dict(case=name,exit_code=result.returncode,expected_exit=expected,seconds=seconds,warning_count=value['diagnostics']['warning_count'],marker=marker,source_sha256=hashlib.sha256((target/'submitted.sas').read_bytes()).hexdigest() if (target/'submitted.sas').is_file() else None)
        records.append(record)
        print(json.dumps(record),flush=True)
        return value
    try:
        run('positive',['--code','proc sql noprint;select count(*),min(age),max(age) into :py_n trimmed,:py_min trimmed,:py_max trimmed from sashelp.class;quit;%put PYTHON_PORT_CLASS=&py_n MIN=&py_min MAX=&py_max;'],marker='PYTHON_PORT_CLASS=19 MIN=11 MAX=16')
        source=out/'inputs'
        source.mkdir()
        (source/'initial.sas').write_text('%let py_label=passed;',encoding='utf-8')
        (source/'values.tsv').write_text('value\n10\n20\n',encoding='utf-8')
        (source/'helper.sas').write_text('%macro helper;%put PYTHON_PORT_HELPER=loaded;%mend;',encoding='utf-8')
        (source/'Probe.sas').write_text('''%macro probe;
%helper;
data work.python_values; infile "values.tsv" dsd dlm='09'x firstobs=2;input value;run;
proc sql noprint;select sum(value) into :py_total trimmed from work.python_values;quit;
%global py_saved_total;%let py_saved_total=&py_total;
%put PYTHON_DEP_PASS=&py_total INIT=&py_label;
%mend;''',encoding='utf-8')
        (source/'main.sas').write_text('''%include "initial.sas";
%probe;
proc export data=work.python_values outfile="%sysfunc(pathname(work))/py_values.csv" dbms=csv replace;run;
data _null_;file "%sysfunc(pathname(work))/py_proof.txt";put 'PYTHON_PORT_TRANSFER_OK';run;
%put PYTHON_DEP_WORK=%sysfunc(pathname(work));
''',encoding='utf-8')
        result=run('dependencies',['--file',str(source/'main.sas'),'--macro-dir',str(source)],marker='PYTHON_DEP_PASS=30 INIT=passed')
        if len(result['transfers']['uploads'])!=4 or not any(item.get('archive_transfer') for item in result['transfers']['uploads']):
            raise AssertionError('Expected four dependency files in batched transfer')
        remote=re.search(r'^PYTHON_DEP_WORK=([^\r\n]+)',result['log'],re.M)[1].strip()
        local=out/'collected'
        run('download',['--download-file',remote+'/py_values.csv','--download-local-path',str(local/'values.csv'),'--download-file',remote+'/py_proof.txt','--download-local-path',str(local/'proof.txt')])
        with (local/'values.csv').open(newline='') as handle:
            rows=list(csv.DictReader(handle))
        if [float(row['value']) for row in rows]!=[10,20] or (local/'proof.txt').read_text().strip()!='PYTHON_PORT_TRANSFER_OK':
            raise AssertionError('Downloaded numerical/text values differ')
        run('negative',['--code','proc print data=work.__python_port_absent__;run;'],expected=1)
        run('recovery',['--code','%put PYTHON_PORT_RECOVERY=&py_saved_total;'],marker='PYTHON_PORT_RECOVERY=30')
        run('printto_error',['--code','proc printto log="%sysfunc(pathname(work))/py_hidden.log" new;run;proc print data=work.__python_port_absent__;run;'],expected=1)
        run('timeout',['--run-timeout-seconds','2','--code','data _null_;rc=sleep(20,1);run;'],expected=124)
        run('after_timeout',['--code','%put PYTHON_PORT_FRESH_SESSION=ready;'],marker='PYTHON_PORT_FRESH_SESSION=ready')
    finally:
        subprocess.run(common+['--kill-saspy-sessions','--output-prefix',str(out/'close')],cwd=ROOT,env=env,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL,timeout=60)
        (out/'execution.json').write_text(json.dumps(dict(runtime='python',python=sys.executable,scope='SAS runtime and saved-plot examples; not an AI/token/cost benchmark',started_utc=datetime.now(timezone.utc).isoformat(),cases=records),indent=2),encoding='utf-8')
    if args.figures:
        for case in ('hello','clustergram','gene_gtf','oncoprint','forest','multi_gwas_gtf'):
            command=[sys.executable,str(ROOT/'examples/poc/run_example.py'),'--case',case,'--outdir',str(out/('poc_'+case)),'--session-id',session+'_figures','--saspy-cfgname',args.saspy_cfgname]
            if args.saspy_cfgfile:
                command+=['--saspy-cfgfile',args.saspy_cfgfile]
            start=time.perf_counter()
            result=subprocess.run(command,cwd=ROOT,env=env,capture_output=True,timeout=900)
            (out/('poc_'+case+'_console.txt')).write_bytes(result.stdout+result.stderr)
            if result.returncode:
                raise AssertionError(f'PoC {case} failed; inspect its console and SAS log')
            record=dict(case='poc_'+case,exit_code=0,seconds=round(time.perf_counter()-start,3),validation=json.loads((out/('poc_'+case)/'run.json').read_text(encoding='utf-8')))
            records.append(record)
            print(json.dumps(record),flush=True)
            (out/'execution.json').write_text(json.dumps(dict(runtime='python',scope='SAS runtime and saved-plot examples; not an AI/token/cost benchmark',cases=records),indent=2),encoding='utf-8')
        subprocess.run([*common[:common.index('--session-id')],'--session-id',session+'_figures',*common[common.index('--session-id')+2:],'--kill-saspy-sessions','--output-prefix',str(out/'close_figures')],cwd=ROOT,env=env,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL,timeout=60)

if __name__=='__main__':
    main()
