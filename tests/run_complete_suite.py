#!/usr/bin/env python3
"""Inventory and run standalone offline tests, preserving per-script evidence.

Live tests require explicit opt-in and are recorded separately, never silently
treated as passing. Catalog files are inputs, not standalone test programs.
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

ROOT = Path(__file__).resolve().parents[1]


def kind(path):
    if path.suffix not in {'.pl', '.py', '.sh'}:
        return 'data'
    if path.name == Path(__file__).name:
        return 'orchestrator'
    if path.name=='test_live_open_code_preflight.py':
        return 'offline'
    if path.name in ('new_validation_tasks_001_100.py','covid19_gwas_validation_tasks_001_500.py',
                     'new_validation_tasks_001_100.pl','covid19_gwas_validation_tasks_001_500.pl'):
        return 'offline'
    if 'live' in path.stem:
        return 'live'
    if path.name.startswith('test_'):
        return 'offline'
    return 'catalog'


def main(argv=None):
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--perl', default=shutil.which('perl'))
    p.add_argument('--bash', help='Bash executable; Windows prefers Git Bash over the WSL launcher.')
    p.add_argument('--timeout', type=int, default=240)
    p.add_argument('--language',choices=('all','python','perl','shell'),default='all')
    p.add_argument('--only', help='Comma-separated exact file names')
    p.add_argument('--out', type=Path, default=ROOT/'MCP4SAS_Use_Python/test-results/complete-suite')
    args = p.parse_args(argv)
    if not args.bash:
        args.bash=os.environ.get('TEST_BASH')
        if not args.bash and os.name=='nt':
            git=shutil.which('git')
            candidate=Path(git).resolve().parents[1]/'bin/bash.exe' if git else None
            if candidate and candidate.is_file():args.bash=str(candidate)
        args.bash=args.bash or shutil.which('bash')
    if args.timeout <= 0:
        p.error('--timeout must be positive')
    paths = sorted((ROOT/'tests').iterdir())
    paths = [v for v in paths if v.is_file()]
    requested = set(args.only.split(',')) if args.only else None
    if requested and requested - {v.name for v in paths}:
        p.error('Unknown tests: '+', '.join(sorted(requested-{v.name for v in paths})))
    args.out.mkdir(parents=True, exist_ok=True)
    records = []
    env = dict(os.environ, OPEN_RESULT='0', SAS_ODA_AUTOLOAD_MACROS='0',
               PIPELINE_PYTHON_BIN=Path(sys.executable).as_posix())
    if args.bash:
        env['TEST_BASH']=args.bash
    failures = 0
    for path in paths:
        record = dict(file=path.name, kind=kind(path), sha256=hashlib.sha256(path.read_bytes()).hexdigest(),
                      status='not_run', reason='Requires explicit live run' if kind(path)=='live' else '')
        selected_language={'all':True,'python':path.suffix=='.py','perl':path.suffix=='.pl','shell':path.suffix=='.sh'}[args.language]
        if record['kind'] == 'offline' and selected_language and (not requested or path.name in requested):
            executable = {'.pl': args.perl, '.py': sys.executable, '.sh': args.bash}[path.suffix]
            if not executable:
                record.update(status='blocked', reason='Required interpreter not found')
                failures += 1
            else:
                command = [executable, path.as_posix()]
                log = args.out/(path.name+'.log')
                start = time.monotonic()
                try:
                    with log.open('wb') as handle:
                        result = subprocess.run(command, cwd=ROOT, env=env, stdout=handle,
                                                stderr=subprocess.STDOUT, timeout=args.timeout)
                    record.update(status='pass' if result.returncode==0 else 'fail', exit_code=result.returncode)
                except subprocess.TimeoutExpired:
                    record.update(status='timeout', reason='Per-script timeout exceeded')
                except OSError as exc:
                    record.update(status='blocked', reason=str(exc))
                record.update(seconds=round(time.monotonic()-start,3), command=command, log=str(log))
                output = log.read_text(encoding='utf-8', errors='replace') if log.exists() else ''
                record['tap_not_ok'] = len(re.findall(r'^not ok\b',output,re.M))
                # Some legacy scripts accidentally exit zero after a failed check.
                if record['tap_not_ok']:
                    record['status']='fail'
                failures += record['status']!='pass'
                print(f"{path.name}: {record['status']} ({record['seconds']} s)", flush=True)
        records.append(record)
        (args.out/'coverage.json').write_text(json.dumps(dict(python=sys.version, results=records),indent=2)+'\n',encoding='utf-8')
    return int(bool(failures))


if __name__=='__main__':
    raise SystemExit(main())
