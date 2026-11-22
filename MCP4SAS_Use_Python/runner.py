"""Native Python orchestration of the existing SASPy/ZIP protocol."""
import os
from pathlib import Path
import re
from . import diagnostics
from .dependencies import Plan
from .local_home import expand_code_paths
from .tempfiles import Scratch
from .transport import Backend

def guard_printto(code):
    from .source_analysis import mask_noncode
    if not re.search(r'\bproc\s+printto\b',mask_noncode(code),re.I):
        return code
    return '%let syscc=0;\n'+code+'''\nproc printto; run;
%macro _pipeline_check_printto;
%if %sysevalf(&syscc >= 8) %then %put ERROR: SAS redirected log reported SYSCC=&syscc.;
%mend;
%_pipeline_check_printto;
%sysmacdelete _pipeline_check_printto;
'''

class Runner:
    def __init__(self,session_id=None,timeout=3600,cfgname=None,cfgfile=None,local_home=None,archive_transfers=True,skip_upload_if_same=True,backend_factory=Backend,timeout_grace_seconds=15):
        env=dict(SAS_ODA_AUTOLOAD_MACROS=os.environ.get('SAS_ODA_AUTOLOAD_MACROS','0'))
        if cfgname:
            env['SASPY_CFGNAME']=cfgname
        if cfgfile:
            env['SASPY_CFGFILE']=str(Path(cfgfile).resolve(strict=True))
        self.backend=backend_factory(session_id=session_id,timeout=timeout,timeout_grace_seconds=timeout_grace_seconds,env=env,local_home=local_home)
        self.archive_transfers=archive_transfers
        self.skip_upload_if_same=skip_upload_if_same
        self.local_home=local_home

    def home(self):
        response=self.backend.call('gethome')
        home=response['home']
        if response.get('local'):
            home=home.replace('\\','/')
            # Resolve quoted ~/ input paths for local SAS even without an
            # explicit HOME option. The next request configures the matching
            # SAS fileref and PIPELINE_SAS_HOME once, in this same session.
            self.local_home=home
            self.backend.local_home=home
        return home

    def transfer(self,uploads=(),downloads=()):
        return self.backend.call('bulk_transfer',payload=dict(uploads=list(uploads),downloads=list(downloads),archive_transfers=self.archive_transfers))['value']

    def run(self,code,source_file=None,macro_dir=None,uploads=(),keep_intermediates=False,prepared_plan=None,submitted_path=None):
        plan=prepared_plan or Plan(code,source_file,macro_dir,uploads)
        with Scratch(keep=keep_intermediates) as scratch:
            processed,manifest=plan.prepare(scratch,self.home(),self.skip_upload_if_same)
            transferred=self.transfer(uploads=manifest) if manifest else dict(uploads=[],downloads=[])
            processed=guard_printto(expand_code_paths(processed,self.local_home))
            if submitted_path:
                Path(submitted_path).write_text(processed,encoding='utf-8',newline='\n')
            response=self.backend.call('submit',code=processed,load_macros=os.environ.get('SAS_ODA_AUTOLOAD_MACROS','0').lower() in ('1','true','yes','on'))
        log=response.get('log','')
        return dict(log=log,lst=response.get('lst',''),processed_code=processed,dependencies=plan.as_dict(),transfers=transferred,diagnostics=diagnostics.classify(log),macro_bootstrap_meta=response.get('macro_bootstrap_meta',{}))

    def fileinfo(self,path):
        return self.backend.call('fileinfo',remote_path=path)['info']
    def run_code(self,code,**kwargs):
        return self.run(code,**kwargs)
    def run_file(self,path,**kwargs):
        from .dependencies import read_source
        return self.run(read_source(path),source_file=path,**kwargs)
    def upload(self,path,skip_if_same=True):
        value=self.transfer(uploads=[dict(local_path=str(Path(path).resolve(strict=True)),skip_if_same=skip_if_same)])
        return value['uploads'][0]['remote_path']
    def download(self,remote_path,local_path=None):
        value=self.transfer(downloads=[dict(remote_path=remote_path,local_path=str(Path(local_path or Path(remote_path).name).resolve()))])
        return value['downloads'][0]['local_path']
    def dirlist(self,path):
        return self.backend.call('dirlist',remote_path=path)['files']
    filesindir=dirlist
    get_sas_home_path=home
    transfer_many=transfer
    def delete(self,path,parent='~'):
        return self.backend.call('delete',remote_file=path,remote_dir=parent)
    def delete_many(self,paths,parent='~'):
        return [self.delete(path,parent) for path in paths]
    def close(self,force=False):
        self.backend.close(force=force)
    def __enter__(self):
        return self
    def __exit__(self,*args):
        self.close()
