#!/usr/bin/env python3
"""Opt-in ODA acceptance checks for either repository's actual CLI runners.

No credentials belong in this file. Configure SASPy through its usual private
configuration/environment. --poc-dir selects the retained MCP4SAS PoC package.
"""
import argparse
import contextlib
import hashlib
import json
import os
from pathlib import Path
import re
import runpy
import secrets
import shutil
import socket
import subprocess
import sys
import time


def digest(path):return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--live',action='store_true',required=True)
    p.add_argument('--repo-root',type=Path,required=True)
    p.add_argument('--poc-dir',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True)
    p.add_argument('--perl',required=True)
    p.add_argument('--languages',nargs='+',choices=('perl','python'),default=['perl','python'])
    p.add_argument('--cases',nargs='+',default=['forest','clustergram','oncoprint','multi_gwas_gtf'])
    a=p.parse_args();root=a.repo_root.resolve();poc=a.poc_dir.resolve();out=a.out.resolve()
    out.mkdir(parents=True,exist_ok=False)
    shutil.copyfile(__file__,out/'executed_harness.py')
    manifest=json.loads((poc/'manifest.json').read_text(encoding='utf-8-sig'))
    cases={x['id']:x for x in manifest['cases']}
    validator=runpy.run_path(str(poc.parent.parent/'MCP4SAS_Use_Python/poc.py'))['validate']
    report={'target':'oda','repo':str(root),'revision':subprocess.check_output(['git','rev-parse','HEAD'],cwd=root,text=True).strip(),
            'source_hashes':{},'runners':[],'scope':'Actual ODA saved-program execution; prepared GTEx/PGC summaries and synthetic oncoprint. No upstream study, AI/token benchmark or full GWAS preprocessing rerun.'}
    deps='DiffGWASDeps' if (root/'DiffGWASDeps').is_dir() else 'MCPDeps'
    for rel in ('run_sas_codes_or_files_in_ODA.pl','run_sas_codes_or_files_in_ODA.py',deps+'/SAS_ODA_Runner.pm',deps+'/sas_oda_session_server.py'):
        report['source_hashes'][rel]=digest(root/rel)
    def save():
        (out/'acceptance.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    save()
    for language in a.languages:
        folder=out/language;folder.mkdir()
        token='oda_live_'+secrets.token_hex(6)
        env=dict(os.environ,SASPY_CFGNAME='oda',OPEN_RESULT='0',SAS_ODA_AUTOLOAD_MACROS='0',PERLMCP_SASPY_LOAD_MACROS='0',
                 PIPELINE_SKIP_SAS_ODA_AUTH_BOOTSTRAP='1',MCP4SAS_PYTHON_STATE_DIR=str(folder/'backend-state'))
        env.pop('SAS_LOCAL_HOME_DIR',None)
        with socket.socket() as server:
            server.bind(('127.0.0.1',0));port=server.getsockname()[1]
        if port==65055:raise RuntimeError('Refusing the user helper port')
        env['SAS_ODA_SESSION_PORT']=str(port)
        env['SAS_ODA_SESSION_DEBUG_LOG']=str(folder/'helper.log').replace('\\','/')
        cygpath=Path(a.perl).with_name('cygpath.exe')
        def client(path):
            if language=='perl' and os.name=='nt':
                return subprocess.check_output([str(cygpath),'-u',str(path)],env=env,text=True).strip()
            return str(path)
        interpreter=a.perl if language=='perl' else sys.executable
        script=root/('run_sas_codes_or_files_in_ODA.'+('pl' if language=='perl' else 'py'))
        common=[interpreter,client(script),'--persistent','--session-id',token,'--saspy-cfgname','oda','--no-open-html','--run-timeout-seconds','600']
        row={'language':language,'session':token,'stages':[],'figures':[],'cleanup':None};report['runners'].append(row);save()
        remote_inputs=[]
        def action(label,code=None,extra=None):
            target=folder/(token+'_'+label);argv=common+['--output-prefix',client(target)]
            source=None
            if code is not None:
                source=folder/(label+'.sas');source.write_text(code,encoding='utf-8',newline='\n')
                argv+=['--file',client(source)]
            argv+=extra or []
            started=time.monotonic()
            r=subprocess.run(argv,cwd=root,env=env,capture_output=True,timeout=660)
            (folder/(label+'.console.log')).write_bytes(r.stdout+b'\n'+r.stderr)
            logpath=target/'output.html.info.txt'
            log=logpath.read_text(encoding='utf-8',errors='replace') if logpath.exists() else (r.stdout+r.stderr).decode('utf-8',errors='replace')
            rec={'label':label,'exit_code':r.returncode,'seconds':round(time.monotonic()-started,3),
                 'log_sha256':digest(logpath) if logpath.exists() else None,
                 'source_sha256':digest(source) if source else None,
                 'warnings':re.findall(r'^\s*WARNING:[^\r\n]*',log,re.M)}
            row['stages'].append(rec);save();print(json.dumps({'language':language,**rec},ensure_ascii=False),flush=True)
            if r.returncode:raise AssertionError(label+' failed; inspect '+str(folder/(label+'.console.log')))
            if code is not None:
                errors=re.findall(r'^\s*ERROR(?:\s+\d+[-:]|:)[^\r\n]*',log,re.M)
                assert not errors,(label,errors)
            return target,log
        def html(path,needle='Alfred'):
            files=list(path.glob('*.html'));assert files and any(needle in x.read_text(errors='replace') for x in files),'Missing actual HTML: '+str(path)
        try:
            target,log=action('class_and_create',"""options notes source;
proc print data=sashelp.class(obs=5);run;
data work.a;set sashelp.class;run;
%put ODA_TEST_PID=&sysjobid;
%put ODA_TEST_PLATFORM=&sysscp;
%put ODA_TEST_WORK=%sysfunc(pathname(work));
""")
            html(target)
            pid=re.search(r'^ODA_TEST_PID=(\S+)',log,re.M);assert pid
            assert re.search(r'^ODA_TEST_PLATFORM=LIN',log,re.M), 'ODA must be Linux'
            work=re.search(r'^ODA_TEST_WORK=([^\r\n]+)',log,re.M);assert work
            assert '.oda.sas.com' in work[1], 'The SAS WORK host must identify ODA'
            row['sas_pid']=pid[1];row['oda_work']=work[1].strip();save()
            for name,code in [('implicit_print','proc print;run;'),('explicit_print','proc print data=work.a;run;'),
                              ('large_source_print','/* source staging regression */\n'*1500+'proc print data=work.a;run;')]:
                target,log=action(name,code+'\n%put ODA_TEST_PID=&sysjobid;')
                html(target)
                assert re.search(r'19 observations read from the data set WORK\.A',log),'Expected 19 WORK.A rows'
                assert re.search(r'^ODA_TEST_PID='+re.escape(pid[1])+r'\s*$',log,re.M),'SAS session changed'
            inputs=[]
            for index,value in enumerate((11,22)):
                file=folder/(token+f'_{index}.tsv');file.write_text('x\n'+str(value)+'\n',newline='\n')
                inputs.append(file);remote_inputs.append('~/'+file.name)
            extra=[]
            for index,file in enumerate(inputs):
                extra+=['--upload-file',client(file),'--download-file','~/'+file.name,'--download-local-path',client(folder/f'returned_{index}.tsv')]
            code=''
            for index,file in enumerate(inputs):code+=f'data work.t{index};infile "~/{file.name}" firstobs=2;input x;run;\n'
            code+='data work.port_values;set work.t0 work.t1;run;\nproc sql noprint;select count(*),sum(x) into :_n trimmed,:_sum trimmed from work.port_values;quit;\n'
            code+=f'%macro {token}_verify; %if &_n=2 and &_sum=33 %then %put ODA_TRANSFER_PASS=33; %else %do; %put ERROR: Bad transferred values; %abort cancel; %end; %mend; %{token}_verify;\n'
            target,log=action('transfer_roundtrip',code,extra)
            assert re.search(r'^ODA_TRANSFER_PASS=33\s*$',log,re.M)
            assert all(digest(file)==digest(folder/f'returned_{i}.tsv') for i,file in enumerate(inputs))
            child=folder/(token+'_child.sas');parent=folder/(token+'_parent.sas')
            child.write_text(f'%macro {token}_calc; proc sql noprint;select sum(x) into :_nested trimmed from work.port_values;quit;%if &_nested=33 %then %put ODA_NESTED_PASS=33; %else %put ERROR: Bad nested macro result;%mend;\n')
            parent.write_text(f'%include "{child.name}";\n')
            remote_inputs+=['~/'+child.name,'~/'+parent.name,'~/include_debug_'+token+'_nested_macro.log']
            target,log=action('nested_macro',f'%include "{parent.as_posix()}";\n%{token}_calc;\n',['--macro-dir',client(folder)])
            assert re.search(r'^ODA_NESTED_PASS=33\s*$',log,re.M)
            target,log=action('macro_query','%macroparas(macrorgx=GTEx,numlines2print=0,print_outdsd=1);')
            count=re.search(r'^MACROPARAS_MATCH_COUNT=(\d+)',log,re.M);assert count and int(count[1])>0
            html(target,'GTEx');row['gtex_macros_found']=int(count[1]);save()
            for case_id in a.cases:
                case=cases[case_id];program=poc/case['program'];raw=program.read_bytes()
                assert case['sha256'] in (digest(program),hashlib.sha256(raw.replace(b'\r\n',b'\n')).hexdigest()),'Frozen program hash differs: '+case_id
                code=raw.decode('utf-8-sig').replace('\r\n','\n');uploads=[];input_records=[]
                for item in case['inputs']:
                    original=poc/item['file'];rawinput=original.read_bytes()
                    assert item['sha256'] in (digest(original),hashlib.sha256(rawinput.replace(b'\r\n',b'\n')).hexdigest())
                    renamed=folder/(token+'_'+original.name);shutil.copyfile(original,renamed)
                    code=code.replace(original.name,renamed.name)
                    uploads+=['--upload-file',client(renamed)];remote_inputs.append('~/'+renamed.name)
                    input_records.append({'source':item['file'],'sha256':digest(original),'remote_basename':renamed.name})
                target,log=action(case_id+'_submit',code,uploads)
                assert re.search(r'^'+re.escape(case['completion_marker'])+r'\s*$',log,re.M)
                remote=re.search(r'^POC_OUT=([^\r\n]+)',log,re.M);assert remote
                files=folder/case_id/'files';files.mkdir(parents=True)
                extra=[]
                for name in case['files']:
                    (files/name).parent.mkdir(parents=True,exist_ok=True)
                    extra+=['--download-file',remote[1].strip().rstrip('/')+'/'+name,'--download-local-path',client(files/name)]
                action(case_id+'_collect',extra=extra)
                checks=validator(case_id,files)
                row['figures'].append({'case':case_id,'original_program_sha256':digest(program),
                    'adaptation':'Only input basenames are uniquely prefixed to avoid shared HOME collisions.',
                    'inputs':input_records,'checks':checks,
                    'artifacts':{name:{'bytes':(files/name).stat().st_size,'sha256':digest(files/name)} for name in case['files']}});save()
            cleanup=[]
            for name in sorted(set(remote_inputs)):cleanup+=['--delete-file',name,'--file-info',name]
            target,log=action('cleanup_inputs',extra=cleanup)
            if language=='perl':
                console=(folder/'cleanup_inputs.console.log').read_text(errors='replace')
                assert len(re.findall(r'^EXISTS\t0\s*$',console,re.M))==len(set(remote_inputs))
            else:
                result=json.loads((target/'result.json').read_text())
                assert len(result['file_info'])==len(set(remote_inputs)) and all(not x['exists'] for x in result['file_info'].values())
            row['cleanup']={'unique_remote_inputs':len(set(remote_inputs)),'verified_absent':True}
            row['passed']=True;save()
        except BaseException as exc:
            row['passed']=False;row['failure']=str(exc);save();raise
        finally:
            if language=='python':
                closed=subprocess.run(common+['--kill-saspy-sessions','--output-prefix',client(folder/'close')],cwd=root,env=env,capture_output=True,timeout=50)
                (folder/'close.console.log').write_bytes(closed.stdout+closed.stderr)
                row['close_exit_code']=closed.returncode
            else:
                def rpc(payload):
                    data=json.dumps(payload).encode()
                    with socket.create_connection(('127.0.0.1',port),timeout=20) as sock:
                        sock.sendall(len(data).to_bytes(8,'big')+data)
                        def recv(size):
                            data=b''
                            while len(data)<size:
                                chunk=sock.recv(size-len(data))
                                if not chunk:raise EOFError('Incomplete helper response')
                                data+=chunk
                            return data
                        size=int.from_bytes(recv(8),'big')
                        return json.loads(recv(size))
                owner=None
                with contextlib.suppress(OSError,EOFError):owner=rpc({'cmd':'ping'})
                if deps=='DiffGWASDeps':
                    cfgfile=env.get('SASPY_CFGFILE','')
                    if os.name=='nt' and cfgfile.startswith('/'):
                        cfgfile=subprocess.check_output([str(cygpath),'-am',cfgfile],env=env,text=True).strip()
                    with contextlib.suppress(OSError,EOFError):
                        row['close_session']=rpc({'cmd':'close_session','session_id':token,'sas_config':{'cfgname':'oda','cfgfile':cfgfile.replace('\\','/')}})
                if os.name=='nt' and owner and owner.get('status')=='ok' and isinstance(owner.get('pid'),int):
                    # The upstream Perl helper has no close_session RPC. Stop
                    # only our fresh helper's process tree, including its Java
                    # bridge; never use a global process-name kill or user port.
                    closed=subprocess.run(['taskkill.exe','/PID',str(owner['pid']),'/T','/F'],env=env,capture_output=True,timeout=30)
                    (folder/'close.console.log').write_bytes(closed.stdout+closed.stderr)
                    row['owned_helper_pid']=owner['pid'];row['close_exit_code']=closed.returncode
                else:
                    with contextlib.suppress(OSError,EOFError):rpc({'cmd':'shutdown'})
            save()
    report['passed']=all(x.get('passed') for x in report['runners']);save()
    print('PASS: live ODA acceptance, persistent WORK, file integrity, macros and selected figures.')


if __name__=='__main__':main()
