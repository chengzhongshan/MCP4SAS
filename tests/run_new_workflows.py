"""Execute source-traceable new workflows through either public MCP4SAS CLI.

This is a maintainer test driver; the Python product runner does not call Perl.
Numerical CSVs, actual runtime markers, process status, and rendering are checked
independently. No expected values are embedded in submitted SAS programs.
"""
import argparse
import csv
import hashlib
import json
import math
import os
from pathlib import Path
import re
import secrets
import shutil
import socket
import subprocess
import sys
import time
import xml.etree.ElementTree as ET

ROOT=Path(__file__).resolve().parents[1]

def verify(case,file):
    problems=[];expected=case['expected'];actual={}
    if not file.is_file():return ['Missing numerical CSV'],0
    with file.open(encoding='utf-8-sig',newline='') as handle:
        for row in csv.DictReader(handle):
            key=row.get('metric');raw=row.get('value','').strip()
            if key in actual:problems.append('Duplicate metric '+str(key))
            try:actual[key]=None if raw in ('','.','NA') else float(raw)
            except ValueError:problems.append('Invalid numerical value '+repr(raw));actual[key]=raw
    if set(actual)!=set(expected):
        problems.append('Metric keys differ: missing='+str(sorted(set(expected)-set(actual))[:8])+' extra='+str(sorted(set(actual)-set(expected))[:8]))
    for key,wanted in expected.items():
        got=actual.get(key)
        if wanted is None:
            if got is not None:problems.append(f'{key}: expected missing, got {got}')
        elif not isinstance(got,(float,int)) or not math.isfinite(got) or not math.isclose(got,wanted,rel_tol=case['tolerance'],abs_tol=case.get('absolute_tolerance',1e-12)):
            problems.append(f'{key}: expected {wanted}, got {got}')
    return problems,len(expected)

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--live',action='store_true',required=True)
    p.add_argument('--collection',choices=('library_workflows500','online_samples500'),required=True)
    p.add_argument('--runtime',choices=('python','perl'),default='python')
    p.add_argument('--pilot',action='store_true');p.add_argument('--only')
    p.add_argument('--batch-size',type=int,default=25);p.add_argument('--out',type=Path,required=True)
    p.add_argument('--perl',default='C:/Users/cheng/AppData/Local/MCP4SAS/cygwin/bin/perl.exe')
    p.add_argument('--saspy-cfgname',default='oda')
    p.add_argument('--saspy-cfgfile',type=Path,default=ROOT/'sascfg_personal.py')
    args=p.parse_args()
    if not 1<=args.batch_size<=50:p.error('batch-size must be 1..50')
    directory=ROOT/'tests'/args.collection
    manifest=json.loads((directory/'manifest.json').read_text(encoding='utf-8'))
    cases=manifest['cases']
    if args.pilot:
        seen=set();cases=[c for c in cases if c['family'] not in seen and not seen.add(c['family'])]
    if args.only:cases=[c for c in cases if c['id'] in args.only.split(',')]
    if not cases:raise ValueError('No selected cases')
    programs={}
    for c in cases:
        raw=(directory/c['file']).read_bytes()
        if hashlib.sha256(raw).hexdigest()!=c['sha256']:raise ValueError('Source changed '+c['id'])
        programs[c['id']]=raw.decode('utf-8')
    output=args.out.resolve();output.mkdir(parents=True,exist_ok=False)
    runtime_files=['run_sas_codes_or_files_in_ODA.pl','run_sas_codes_or_script_in_ODA.pl',
        'MCPDeps/SAS_ODA_Runner.pm','MCPDeps/SAS_Source_Analysis.pm','MCPDeps/sas_archive_transfer.py',
        'MCP4SAS_Use_Python/cli.py','MCP4SAS_Use_Python/dependencies.py','MCP4SAS_Use_Python/source_analysis.py',
        'MCP4SAS_Use_Python/backend/sas_archive_transfer.py']
    runtime_hashes={}
    for name in runtime_files:
        raw=(ROOT/name).read_bytes();runtime_hashes[name]=hashlib.sha256(raw).hexdigest()
        copy=output/'runtime_sources'/name;copy.parent.mkdir(parents=True,exist_ok=True);copy.write_bytes(raw)
    # Isolate remote HOME basenames as well as SAS WORK/session state. This
    # also relocates frozen input aliases for a checkout on another computer.
    namespace='t'+secrets.token_hex(3)+'_'
    fixture_root=output/'fixtures';macro_dir=fixture_root/'macros';macro_dir.mkdir(parents=True)
    for original in (directory/'macros').glob('*.sas'):
        target=macro_dir/original.name.replace('n26_',namespace)
        target.write_text(original.read_text(encoding='utf-8').replace('n26_',namespace),encoding='utf-8',newline='\n')
    replacements={};input_dir=fixture_root/'inputs';input_dir.mkdir()
    for original in (directory/'inputs').glob('*'):
        target=input_dir/original.name.replace('n26_',namespace);shutil.copyfile(original,target)
        alias=manifest.get('generated_repository_root',ROOT.as_posix())+'/'+original.relative_to(ROOT).as_posix()
        replacements[alias]=target.as_posix()
    for identifier,program in programs.items():
        for alias,target in replacements.items():program=program.replace(alias,target)
        programs[identifier]=program.replace('%n26_','%'+namespace)
    with socket.socket() as listener:
        listener.bind(('127.0.0.1',0));port=listener.getsockname()[1]
    session='new1000_'+secrets.token_hex(10)
    # Local dependency graphs are deliberately resolved and uploaded by each
    # runner. Do not import every unrelated HOME/ Macros definition as well.
    env=dict(os.environ,OPEN_RESULT='0',SAS_ODA_AUTOLOAD_MACROS='0',PYTHONUNBUFFERED='1',
             SAS_ODA_SESSION_PORT=str(port),SASPY_CFGNAME=args.saspy_cfgname,SASPY_CFGFILE=args.saspy_cfgfile.resolve().as_posix(),
             PIPELINE_PYTHON_BIN=sys.executable)
    command=([sys.executable,str(ROOT/'run_sas_codes_or_files_in_ODA.py')] if args.runtime=='python' else
             [args.perl,(ROOT/'run_sas_codes_or_files_in_ODA.pl').as_posix()])
    records=[];batches=[];owned=set();housekeeping={};all_started=time.monotonic()
    def call(extra,label,timeout=300):
        start=time.monotonic()
        proc=subprocess.run(command+extra+['--persistent','--session-id',session,'--run-timeout-seconds','240',
            '--output-prefix',(output/label).as_posix()],cwd=ROOT,env=env,capture_output=True,timeout=timeout)
        (output/(label+'.cli.log')).write_bytes(proc.stdout+proc.stderr)
        return proc.returncode,round(time.monotonic()-start,3)
    def save():
        (output/'results.json').write_text(json.dumps(dict(collection=args.collection,runtime=args.runtime,
            session=session,port=port,target=args.saspy_cfgname,namespace=namespace,runtime_sources=runtime_hashes,housekeeping=housekeeping,selected=len(cases),elapsed_seconds=round(time.monotonic()-all_started,3),
            cases=records,batches=batches),indent=2)+'\n',encoding='utf-8')
    try:
        for offset in range(0,len(cases),args.batch_size):
            group=cases[offset:offset+args.batch_size];label=group[0]['id']+'_'+group[-1]['id']
            file=output/(label+'.sas');file.write_text('%put NEW_WORKFLOW_HOME=%sysfunc(pathname(home));\n'+'\n'.join(programs[c['id']] for c in group),encoding='utf-8',newline='\n')
            rc,seconds=call(['--file',file.as_posix(),'--macro-dir',macro_dir.as_posix()],label)
            log_file=output/label/'output.html.info.txt'
            log=log_file.read_text(encoding='utf-8',errors='replace') if log_file.is_file() else ''
            status_file=output/label/('output.html.run.status.json' if args.runtime=='python' else 'output.run.status.json')
            status=json.loads(status_file.read_text(encoding='utf-8')) if status_file.is_file() else {}
            work=re.findall(r'^NEW_WORKFLOW_OUT=(\S+)\s*$',log,re.M)
            homes=re.findall(r'^NEW_WORKFLOW_HOME=(\S+)\s*$',log,re.M)
            if homes:
                owned.update(homes[-1].rstrip('/')+'/'+p.name for p in fixture_root.glob('*/*') if p.is_file())
            errors=re.findall(r'^ERROR(?:\s+\d+-\d+)?\s*:[^\n]*',log,re.M)
            warnings=re.findall(r'^WARNING[^\n]*',log,re.M)
            result_file=output/label/'result.json'
            if result_file.is_file():
                result=json.loads(result_file.read_text(encoding='utf-8'))
                def paths(value):
                    if isinstance(value,dict):
                        for k,v in value.items():
                            if k=='remote_path' and isinstance(v,str) and Path(v).name.startswith(namespace):owned.add(v)
                            else:paths(v)
                    elif isinstance(value,list):
                        for v in value:paths(v)
                paths(result)
            problems=[]
            if rc or not status.get('complete') or not status.get('success'):problems.append(f'CLI/status failure exit={rc}')
            if errors:problems.append(f'{len(errors)} SAS errors')
            if work:
                download=[]
                for c in group:
                    for name in [c['id']+'.csv',*c.get('assets',[])]:
                        download+=['--download-file',work[-1]+'/'+name,'--download-local-path',(output/'tables'/name).as_posix()]
                (output/'tables').mkdir(exist_ok=True)
                dlrc,dlseconds=call(download,label+'_download')
                if dlrc:problems.append(f'Download failure exit={dlrc}')
            else:
                dlseconds=0;problems.append('Missing actual runtime WORK marker')
            for c in group:
                issues=list(problems)
                count=len(re.findall(r'^NEW_WORKFLOW_DONE='+re.escape(c['id'])+r'\s*$',log,re.M))
                if count!=1:issues.append(f'Expected one runtime completion marker, found {count}')
                numeric,nchecked=verify(c,output/'tables'/(c['id']+'.csv'));issues+=numeric
                for name in c.get('assets',[]):
                    try:
                        graphic=ET.parse(output/'tables'/name).getroot()
                        if not graphic.tag.endswith('svg') or len(list(graphic.iter()))<10:raise ValueError('Empty SVG')
                    except (OSError,ET.ParseError,ValueError) as exc:issues.append('SVG validation: '+str(exc))
                records.append(dict(id=c['id'],family=c['family'],passed=not issues,checks=nchecked,
                    issues=issues,source_sha256=c['sha256'],batch=label))
            batches.append(dict(label=label,exit_code=rc,submit_seconds=seconds,download_seconds=dlseconds,
                errors=errors,warnings=warnings,status=status))
            save();print(f'{args.runtime}/{args.collection} {label}: {sum(c["passed"] for c in records)}/{len(records)} passed; errors={len(errors)}',flush=True)
            if not work and (rc or not log):break
    finally:
        # Restrict deletion to these test-owned names. WORK outputs disappear
        # with this isolated session; ordinary author macro files are untouched.
        if owned:
            # One SAS submission, restricted to exact owned filenames. Calling
            # the remote delete API once per temporary file would dominate a
            # large corpus run, without testing another numerical case.
            cleanup_file=output/'owned_upload_cleanup.sas'
            cleanup_code='data _null_;length path $4096;\n'
            for remote in sorted(owned):
                if not remote.rsplit('/',1)[1].startswith(namespace):raise ValueError('Refusing unowned cleanup path')
                quoted=remote.replace("'","''")
                cleanup_code+=f"path='{quoted}';rc=filename('n26cln',path);if fexist('n26cln') then do;rc=fdelete('n26cln');if rc ne 0 then put 'ERROR: Test-owned cleanup failed ' path= rc=;end;rc=filename('n26cln');\n"
            cleanup_file.write_text(cleanup_code+'run;\n',encoding='utf-8',newline='\n')
            cleanup=['--file',cleanup_file.as_posix()]
            try:
                cleanup_rc,cleanup_seconds=call(cleanup,'owned_upload_cleanup')
                housekeeping['cleanup']=dict(exit_code=cleanup_rc,seconds=cleanup_seconds)
            except Exception as exc:(output/'cleanup_error.txt').write_text(str(exc),encoding='utf-8')
        try:
            close_rc,close_seconds=call(['--kill-saspy-sessions'],'session_close',120)
            housekeeping['close']=dict(exit_code=close_rc,seconds=close_seconds)
        except Exception as exc:(output/'close_error.txt').write_text(str(exc),encoding='utf-8')
        save()
    return int(len(records)!=len(cases) or any(not r['passed'] for r in records)
               or any(v.get('exit_code') for v in housekeeping.values()))

if __name__=='__main__':raise SystemExit(main())
