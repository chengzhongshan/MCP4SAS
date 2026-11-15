"""Opt-in native Python functional counterparts of the Perl live regressions.

Each submission uses the public Python CLI. Fixtures have unique owned names;
the finalizer deletes only those fixtures and closes only the selected session.
This module does not execute Perl, shell commands, or an AI agent.
"""
import argparse
import json
import os
from pathlib import Path
import re
import secrets
import subprocess
import sys
import time

ROOT=Path(__file__).resolve().parents[1]


class Harness:
    def __init__(self,out):
        self.out=out;out.mkdir(parents=True,exist_ok=False)
        self.tag='py'+secrets.token_hex(5);self.session='reg_'+secrets.token_hex(8)
        self.records=[];self.uploads=set();self.directories=set()
        self.env=dict(os.environ,OPEN_RESULT='0',SAS_ODA_AUTOLOAD_MACROS='0')

    def submit(self,label,code=None,*,file=None,extra=(),expected=0,marker=None,diagnostic=None):
        prefix=self.out/label
        command=[sys.executable,(ROOT/'run_sas_codes_or_files_in_ODA.py').as_posix(),
                 '--persistent','--session-id',self.session,'--run-timeout-seconds','120','--output-prefix',prefix.as_posix()]
        if code is not None:
            file=self.out/(label+'.sas');file.write_text(code,encoding='utf-8')
        if file:command+=['--file',str(file)]
        command+=list(extra)
        start=time.monotonic()
        result=subprocess.run(command,cwd=self.out,env=self.env,capture_output=True,timeout=200)
        (self.out/(label+'.terminal.log')).write_bytes(result.stdout+result.stderr)
        log_path=prefix/'output.html.info.txt';status_path=prefix/'output.html.run.status.json'
        log=log_path.read_text(encoding='utf-8') if log_path.exists() else ''
        status=json.loads(status_path.read_text(encoding='utf-8')) if status_path.exists() else {}
        problems=[]
        if result.returncode!=expected:problems.append(f'exit {result.returncode}, expected {expected}')
        if not status.get('complete') or bool(status.get('success'))!=(expected==0):problems.append('missing/inconsistent terminal status')
        if not log:problems.append('missing full log')
        if marker and not re.search('^'+re.escape(marker)+r'[ \t]*\r?$',log,re.M):problems.append('runtime numerical marker absent')
        if diagnostic and not re.search(r'^\s*ERROR(?:\s+\d+-\d+)?:.*'+diagnostic,log,re.I|re.M):problems.append('expected SAS runtime error absent')
        if expected==1 and status.get('failure_class') in ('timeout','runtime_error','sas_oda_space_exhaustion','sas_oda_remote_session_termination'):
            problems.append('infrastructure failure cannot validate an intentional error')
        row=dict(label=label,exit_code=result.returncode,passed=not problems,problems=problems,seconds=round(time.monotonic()-start,3))
        self.records.append(row)
        (self.out/'execution.json').write_text(json.dumps(self.records,indent=2)+'\n',encoding='utf-8')
        print(json.dumps(row),flush=True)
        if problems:raise AssertionError(label+': '+'; '.join(problems))
        return log

    def child(self,name,source):
        file=self.out/(self.tag+'_'+name)
        file.write_text(source,encoding='utf-8');self.uploads.add(file.name)
        return file

    def close(self):
        try:
            if self.uploads:
                extra=[]
                for name in sorted(self.uploads):extra+=['--delete-file','~/'+name]
                self.submit('fixture_cleanup',extra=extra)
            for name in sorted(self.directories):
                self.submit('directory_cleanup_'+name,extra=['--delete-directory-rgx','^'+name+'$'])
        finally:self.submit('session_close',extra=['--kill-saspy-sessions'])


def includes(h,mode):
    a=h.child("author's.sas",'data child;value=27;run;')
    b=h.child('second.sas','data second;value=15;run;')
    path=a.as_posix().replace("'","''")
    statement="%include '"+path+"';"
    variants={
        'inc':"%inc '"+path+"';",
        'direct':statement,
        'dosubl':"data _null_; rc=dosubl('"+statement.replace("'","''")+"');run;",
        'execute':"data _null_;call execute('"+statement.replace("'","''")+"');run;",
        'double':"data _null_;rc=dosubl(\""+statement.replace('"','""')+'\");run;',
        'lists':"%include '"+path+"' '"+b.as_posix()+"';",
    }
    selected=('direct','dosubl','execute','double','lists','inc') if mode=='all' else (mode,)
    for label in selected:
        check="data _null_;set child;if value=27 then put 'PY_INCLUDE_OK';else put 'ERROR: wrong include value';run;"
        if label=='lists':check+="data _null_;set second;if value=15 then put 'PY_SECOND_OK';else put 'ERROR: wrong second value';run;"
        log=h.submit(label,variants[label]+check,marker='PY_INCLUDE_OK')
        if label=='lists':assert re.search(r'^PY_SECOND_OK$',log,re.M)


def macro_case(h):
    name=h.tag+'MiXeD'
    file=h.child('source.sas',f'%macro {name};data found;value=43;run;%mend;')
    # Upload a uniquely named mixed-case basename; deliberately do not make the
    # file discoverable locally under the requested macro's lowercase name.
    actual=h.out/(name+'.SaS');actual.write_bytes(file.read_bytes());h.uploads.add(actual.name)
    h.submit('macro_upload',extra=['--upload-file',actual.as_posix()])
    h.submit('macro_case',f'%{name.lower()};data _null_;set found;if value=43 then put "PY_CASE_OK";else put "ERROR: wrong macro";run;',marker='PY_CASE_OK')


def run(name,h):
    if name=='cli_cleanup':
        for label,code,expected,extra in (
            ('success','proc print data=sashelp.class(obs=3);run;',0,[]),
            ('failure','proc print data=work.py_cleanup_missing;run;',1,[]),
            ('timeout','data _null_;call sleep(30,1);run;',124,['--run-timeout-seconds','3','--run-timeout-grace-seconds','1']),
            ('retained','proc print data=sashelp.class(obs=3);run;',0,['--keep-intermediate-files'])):
            before=set(h.out.glob('.mcp4sas_work_*'))
            h.submit(label,code,extra=['--no-persistent',*extra],expected=expected,
                     diagnostic='PY_CLEANUP_MISSING' if label=='failure' else None)
            after=set(h.out.glob('.mcp4sas_work_*'))
            assert (len(after-before)==1 if label=='retained' else not after-before),'scratch cleanup/retention contract failed'
    elif name=='builtin_macro_bootstrap':
        log=h.submit('builtins',"%let builtin=%qsubstr(%str(abcdef),1,3);data _null_;if symget('builtin')='abc' then put 'PY_BUILTIN_OK';else put 'ERROR: builtin mismatch';run;",marker='PY_BUILTIN_OK')
        assert 'Injected targeted remote macro loader' not in log
    elif name=='case_insensitive_macro_lookup':macro_case(h)
    elif name in ('deferred_includes','include_literal_paths','include_file_lists','include_abbreviation'):
        includes(h,'all' if name in ('deferred_includes','include_abbreviation') else 'lists' if name=='include_file_lists' else 'direct')
    elif name=='sas_error_recovery':
        h.submit('error','data retained;value=6;run;proc sql;select absent from retained;quit;',expected=1,diagnostic='absent')
        h.submit('recovery',"data _null_;set retained;if value*7=42 then put 'PY_RECOVERY_OK';else put 'ERROR: recovery mismatch';run;",marker='PY_RECOVERY_OK')
    elif name=='deferred_and_printto':
        includes(h,'dosubl')
        h.submit('printto',"filename ownlog temp;proc printto log=ownlog new;run;data bad;set work.py_missing_table;run;proc printto;run;",expected=1,diagnostic='SYSCC')
    elif name=='resolve_macro_loading':
        macro=h.child('unused.sas','%macro py_resolved;data resolved;value=42;run;%mend;')
        actual=h.out/'py_resolved.sas';actual.write_bytes(macro.read_bytes());h.uploads.add(actual.name)
        for mode,expression in [('resolve',"resolve('%py_resolved;')"),('unquote',"%unquote(%nrstr(%py_resolved;))")]:
            code='data _null_;rc=dosubl('+expression+');run;' if mode=='resolve' else expression
            h.submit(mode,code+"data _null_;set resolved;if value=42 then put 'PY_RESOLVE_OK';else put 'ERROR: resolved value';run;",extra=['--macro-dir',h.out.as_posix()],marker='PY_RESOLVE_OK')
    elif name=='gtex_cache_only':
        macro=(ROOT/'examples/sas_macros/Boxplots4GenesInGTExV8_Cached.sas').read_text(encoding='utf-8')
        data="data probe_cache;length rownames $16 cluster $8 sex $1;do gene=1 to 3;if gene=1 then rownames='MAP3K19';else if gene=2 then rownames='R3HDM1';else rownames='OTHER';do tissue=1 to 2;cluster=cats('t',tissue);do j=1 to 2;sex='F';exp=j;output;sex='M';exp=j+1;output;end;end;end;run;"
        h.submit('cache',macro+data+"%Boxplots4GenesInGTExV8_Cached(Lib4PreviousDsd=work,PreviousDsd=probe_cache,dsdout=probe_out);proc sql noprint;select count(*) into :outn from probe_out;quit;%if &outn=16 %then %do;%put PY_CACHE_OK;%end;%else %do;%put ERROR: cache count;%end;",marker='PY_CACHE_OK')
        h.submit('missing_cache',macro+'%Boxplots4GenesInGTExV8_Cached(Lib4PreviousDsd=work,PreviousDsd=probe_absent);',expected=1,diagnostic='GTEX_CACHE_ONLY')
    elif name=='remote_directory_cleanup':
        h.directories.add(h.tag)
        h.submit('setup',f'''%let home=%sysfunc(pathname(HOME));data _null_;
if fileexist("&home/{h.tag}") then put 'ERROR: unique fixture collision';
else do;p=dcreate('{h.tag}',"&home");c=dcreate('child',p);k=dcreate('keep',p);end;run;''')
        options=['--delete-dir','~/'+h.tag,'--delete-directory-rgx','^child$']
        h.submit('dryrun',extra=options+['--delete-directory-dry-run'])
        h.submit('delete_child',extra=options)
        h.submit('verify',f'''%let home=%sysfunc(pathname(HOME));data _null_;
if not fileexist("&home/{h.tag}/child") and fileexist("&home/{h.tag}/keep") then put 'PY_DIRECTORY_OK';else put 'ERROR: directory cleanup mismatch';run;''',marker='PY_DIRECTORY_OK')
    else:raise ValueError('Unknown live regression '+name)


def main(name,argv=None):
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--live',action='store_true',required=True);p.add_argument('--out',type=Path)
    args=p.parse_args(argv)
    out=(args.out or ROOT/'MCP4SAS_Use_Python/test-results'/('native_'+name+'_'+secrets.token_hex(4))).resolve()
    h=Harness(out)
    try:run(name,h)
    finally:h.close()
    return 0
