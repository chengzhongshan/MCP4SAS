"""Worker launched by the MCP server; stdout never shares the MCP stream."""
import json
from pathlib import Path
import shutil
import sys
from .cli import main,atomic_json

def run(path):
    job=json.loads(Path(path).read_text(encoding='utf-8'))
    directory=Path(job['directory'])
    log=directory/'output.html.info.txt'
    code=1
    try:
        if job.get('direct'):
            from .local_direct import execute
            code=execute(job['direct_args'],directory)
        else:
            code=main(job['argv'])
    except BaseException as exc:
        log.write_text('ERROR: Python worker failed: '+str(exc)+'\n',encoding='utf-8')
    if not log.is_file():
        sys.stdout.flush()
        sys.stderr.flush()
        capture=directory/'worker.stdout.txt'
        text=capture.read_text(encoding='utf-8',errors='replace') if capture.is_file() else ''
        log.write_text(text or 'ERROR: No result log was produced. Read worker.stdout.txt.\n',encoding='utf-8')
        if not text and code==0:
            code=1
    copy_error=''
    if job.get('output_file'):
        try:
            target=Path(job['output_file']).resolve()
            if target!=log.resolve():
                target.parent.mkdir(parents=True,exist_ok=True)
                shutil.copyfile(log,target)
        except OSError as exc:
            code=1
            copy_error=str(exc)
    atomic_json(directory/'worker.result.json',dict(exit_code=code,log_path=str(log),copy_error=copy_error,runtime='python'))
    return code

if __name__=='__main__':
    raise SystemExit(run(sys.argv[1]))
