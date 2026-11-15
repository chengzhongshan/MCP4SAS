#!/usr/bin/env python3
"""Opt-in live execution of every frozen PoC through the Python runner.

Run after installing/configuring MCP4SAS. No SAS connection is made without
--live. Logs, submitted code, downloaded outputs and checks stay in --outdir.
Credentials are read by the runner and are never included in this report.
"""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[1]


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--live', action='store_true')
    parser.add_argument('--outdir', required=True)
    parser.add_argument('--saspy-cfgname', default='oda')
    parser.add_argument('--saspy-cfgfile')
    args = parser.parse_args()
    if args.saspy_cfgfile:
        args.saspy_cfgfile = str(Path(args.saspy_cfgfile).resolve(strict=True))
    manifest_path = ROOT / 'examples/poc/manifest.json'
    manifest = json.loads(manifest_path.read_text(encoding='utf-8'))
    sources = []
    for case in manifest['cases']:
        for item in [dict(file=case['program'], sha256=case['sha256']), *case['inputs']]:
            path = ROOT / 'examples/poc' / item['file']
            actual = digest(path)
            if actual != item['sha256']:
                raise ValueError('Source hash differs: ' + item['file'])
            sources.append(dict(file=item['file'], sha256=actual))
    if not args.live:
        print(json.dumps(dict(plan_only=True, cases=[c['id'] for c in manifest['cases']],
                              verified_source_files=len(sources)), indent=2))
        return 0
    out = Path(args.outdir).resolve()
    out.mkdir(parents=True, exist_ok=False)
    session = 'poc_suite_python_' + str(os.getpid())
    env = dict(os.environ, OPEN_RESULT='0', SAS_ODA_AUTOLOAD_MACROS='0')
    config = ['--saspy-cfgname', args.saspy_cfgname]
    if args.saspy_cfgfile:
        config += ['--saspy-cfgfile', args.saspy_cfgfile]
    records = []
    report = dict(started_utc=datetime.now(timezone.utc).isoformat(),
                  runtime='python', python=sys.executable, session=session,
                  manifest_sha256=digest(manifest_path), sources=sources,
                  scope='Saved SAS plotting programs; not AI authoring, token/cost savings or a full research-pipeline validation.',
                  cases=records, complete=False)

    def save():
        (out / 'execution.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')

    save()
    try:
        for case in manifest['cases']:
            name = case['id']
            command = [sys.executable, str(ROOT / 'examples/poc/run_example.py'),
                       '--case', name, '--outdir', str(out / name),
                       '--session-id', session, *config]
            started = time.perf_counter()
            with (out / (name + '_console.txt')).open('wb') as console:
                try:
                    result = subprocess.run(command, cwd=ROOT, env=env, stdout=console,
                                            stderr=subprocess.STDOUT, timeout=1200)
                    record = dict(case=name, exit_code=result.returncode,
                                  seconds=round(time.perf_counter() - started, 3))
                except subprocess.TimeoutExpired:
                    record = dict(case=name, exit_code=124, seconds=1200, timeout=True)
            run_json = out / name / 'run.json'
            if run_json.is_file():
                record['validation'] = json.loads(run_json.read_text(encoding='utf-8'))
            records.append(record)
            save()
            print(json.dumps(record), flush=True)
    finally:
        close = [sys.executable, str(ROOT / 'run_sas_codes_or_files_in_ODA.py'),
                 '--persistent', '--session-id', session, *config,
                 '--kill-saspy-sessions', '--output-prefix', str(out / 'close')]
        try:
            with (out / 'close_console.txt').open('wb') as console:
                result = subprocess.run(close, cwd=ROOT, env=env, stdout=console,
                                        stderr=subprocess.STDOUT, timeout=90)
            report['close_exit_code'] = result.returncode
        except subprocess.TimeoutExpired:
            report['close_exit_code'] = 124
        report['complete'] = (len(records) == len(manifest['cases'])
                              and all(r['exit_code'] == 0 and 'validation' in r for r in records)
                              and report['close_exit_code'] == 0)
        report['finished_utc'] = datetime.now(timezone.utc).isoformat()
        report['total_checks'] = sum(r.get('validation', {}).get('checks', 0) for r in records)
        report['total_warnings'] = sum(len(r.get('validation', {}).get('warnings', [])) for r in records)
        report['source_files_unchanged'] = all(
            digest(ROOT / 'examples/poc' / item['file']) == item['sha256'] for item in sources)
        report['complete'] = report['complete'] and report['source_files_unchanged']
        save()
    print(json.dumps({k: report[k] for k in ('complete', 'total_checks', 'total_warnings',
                                             'close_exit_code', 'source_files_unchanged')}))
    return 0 if report['complete'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
