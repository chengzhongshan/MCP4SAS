"""One-shot local SAS execution without SASPy, Bash or Perl."""
import os
from pathlib import Path
import shutil
import subprocess
from .dependencies import read_source
from .diagnostics import classify
from .transport import stop_owned_process

def execute(args,directory):
    if args.get('persistent') not in (None,False,'0','false') or args.get('session_id'):
        raise ValueError('Direct local SAS is one-shot; use the SASPy tool for session reuse')
    executable=args.get('sas_executable') or os.environ.get('SASPY_LOCAL_SAS_PATH') or shutil.which('sas.exe' if os.name=='nt' else 'sas')
    if not executable:
        raise ValueError('Local SAS executable was not found; set sas_executable or SASPY_LOCAL_SAS_PATH')
    raw=args.get('sas_codes_or_file') or ''
    code=read_source(raw) if '\n' not in raw and len(raw)<4096 and Path(raw).is_file() else raw
    if not code:
        raise ValueError('Supply SAS code or a local SAS file')
    source=directory/'submitted.sas'
    output=str(directory).replace('\\','/').replace("'","''")
    source.write_text("ods html5 path='"+output+"' file='output.html' options(bitmap_mode='inline');\n"+code+'\nods html5 close;\n',encoding='utf-8')
    log=directory/'sas.log'
    command=[executable,'-sysin',str(source),'-log',str(log),'-print',str(directory/'listing.lst'),'-noterminal','-nosplash']
    process=subprocess.Popen(command,stdout=subprocess.DEVNULL,stderr=subprocess.PIPE,start_new_session=os.name!='nt',creationflags=subprocess.CREATE_NO_WINDOW if os.name=='nt' else 0)
    try:
        _,stderr=process.communicate(timeout=int(args.get('run_timeout_seconds') or 3600))
    except subprocess.TimeoutExpired:
        stop_owned_process(process)
        (directory/'output.html.info.txt').write_text('ERROR: Direct SAS process timed out.\n'+(read_source(log) if log.is_file() else ''),encoding='utf-8')
        return 124
    text=read_source(log) if log.is_file() else stderr.decode('utf-8',errors='replace')
    (directory/'output.html.info.txt').write_text('=== SAS Log ===\n'+text+'\n=== Output ===\n',encoding='utf-8')
    if not log.is_file():
        return process.returncode or 1
    return classify(text)['exit_code'] or process.returncode
