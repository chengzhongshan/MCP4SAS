"""Background workers with durable completion records and explicit unknown status."""
import hashlib
import json
import os
from pathlib import Path
import secrets
import subprocess
import sys
from .cli import atomic_json
from .diagnostics import summarize,format_summary
from .source_analysis import is_local_file_candidate
from .tempfiles import pid_alive

ROOT=Path(__file__).resolve().parents[1]

def truth(value):
    return str(value).lower() in ('1','true','yes','y','on')

def as_list(value):
    return value if isinstance(value,list) else [] if value is None else [value]

class Jobs:
    def __init__(self,root=None):
        self.root=Path(root or os.getcwd()).resolve()
        key=hashlib.sha256(str(self.root).encode()).hexdigest()[:20]
        self.index=Path(os.environ.get('MCP4SAS_PYTHON_STATE_DIR') or Path.home()/'.cache/mcp4sas-python')/'jobs'/key
        self.index.mkdir(parents=True,exist_ok=True,mode=0o700)
        self.processes={}

    def submit(self,arguments,direct=False):
        directory=self.root/('SAS_Output_MCP4SAS_Python_'+secrets.token_hex(8))
        directory.mkdir()
        args=dict(arguments)
        raw=args.pop('sas_codes_or_file',None)
        argv=['--output-prefix',str(directory)]
        if raw:
            if is_local_file_candidate(raw) and Path(raw).is_file():
                argv+=['--file',str(Path(raw).resolve())]
            else:
                source=directory/'input.sas'
                source.write_text(raw,encoding='utf-8')
                argv+=['--file',str(source)]
        persistent=truth(args.get('persistent',True))
        if persistent:
            argv+=['--persistent','--session-id',args.get('session_id') or 'mysession']
        for key in ('upload_file','download_file','download_local_path','delete_file','delete_file_rgx','delete_directory_rgx','file_info'):
            for value in as_list(args.get(key)):
                argv+=['--'+key.replace('_','-'),str(value)]
        for key in ('archive_transfers','skip_upload_if_same','cleanup_empty_output_dir'):
            if key in args and not truth(args[key]):
                argv+=['--no-'+key.replace('_','-')]
        for key in ('delete_dir','dir4listing','saspy_cfgname','saspy_cfgfile','run_timeout_seconds','classify_sas_log','macro_dir'):
            if args.get(key) is not None:
                argv+=['--'+key.replace('_','-'),str(args[key])]
        for key in ('delete_directory_dry_run','check_saspy_connection_only','no_run_timeout','kill_saspy_sessions'):
            if truth(args.get(key,False)):
                argv+=['--'+key.replace('_','-')]
        if args.get('dir4local_sas_home'):
            argv+=['--dir4local_sas_home',args['dir4local_sas_home']]
        job=dict(argv=argv,directory=str(directory),output_file=args.get('output_file'),direct=direct,direct_args=args)
        jobfile=directory/'job.json'
        atomic_json(jobfile,job)
        env=dict(os.environ,OPEN_RESULT='0')
        env['PYTHONPATH']=str(ROOT)+(os.pathsep+env['PYTHONPATH'] if env.get('PYTHONPATH') else '')
        with (directory/'worker.stdout.txt').open('wb') as log:
            process=subprocess.Popen([sys.executable,'-m','MCP4SAS_Use_Python.job_worker',str(jobfile)],stdin=subprocess.DEVNULL,stdout=log,stderr=log,cwd=self.root,env=env,start_new_session=os.name!='nt',creationflags=subprocess.CREATE_NO_WINDOW if os.name=='nt' else 0)
        self.processes[process.pid]=process
        atomic_json(self.index/f'{process.pid}.json',dict(pid=process.pid,directory=str(directory)))
        return dict(status='RUNNING',pid=process.pid,log_path=str(directory/'output.html.info.txt'),results_directory=str(directory))

    def poll(self,pid,max_log_chars=16000):
        if not isinstance(pid,int) or pid<=0:
            raise ValueError('PID must be a positive integer')
        record=self.index/f'{pid}.json'
        if not record.is_file():
            return dict(status='UNKNOWN',exit_code=None,pid=pid,message='No Python runtime job record for this PID; success is unconfirmed.')
        directory=Path(json.loads(record.read_text(encoding='utf-8'))['directory'])
        completion=directory/'worker.result.json'
        if pid in self.processes:
            self.processes[pid].poll()
        if not completion.is_file():
            return dict(status='RUNNING' if pid_alive(pid) else 'UNKNOWN',pid=pid,exit_code=None,results_directory=str(directory))
        process=self.processes.get(pid)
        if process is not None:
            try:
                process.wait(timeout=2)
            except subprocess.TimeoutExpired:
                return dict(status='RUNNING',pid=pid,exit_code=None,phase='worker_finalizing',results_directory=str(directory))
        result=json.loads(completion.read_text(encoding='utf-8'))
        log=Path(result['log_path'])
        text=log.read_text(encoding='utf-8',errors='replace') if log.is_file() else ''
        diag=summarize(text)
        if len(text)>max_log_chars:
            text=text[-max_log_chars:]+f'\n[Earlier output omitted; complete log: {log}]'
        result.update(pid=pid,status='COMPLETE' if result['exit_code']==0 else 'FAILED',diagnostics=diag,text=format_summary(diag)+text)
        return result
