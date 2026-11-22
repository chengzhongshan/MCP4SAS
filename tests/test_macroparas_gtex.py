"""Offline plan checks; opt in with --live for real SAS regression execution.

Example: python tests/test_macroparas_gtex.py --live --runner both --perl /path/to/perl
         --saspy-cfgname oda --saspy-cfgfile /path/to/sascfg_personal.py
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
sys.path.insert(0, str(ROOT))
from MCP4SAS_Use_Python.dependencies import Plan

EXPECTED = {'compare_expected_names', 'complete_signature_beyond_preview',
            'preserve_caller_tables', 'preserve_caller_macro_variables',
            'preserve_notes_option', 'zero_matches_clear_previous_results',
            'quoted_directory_list_deduplicated', 'configured_default_directory',
            'sasautos_fileref_directory', 'implicit_print_result_table'}


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--live', action='store_true')
    parser.add_argument('--runner', choices=('python', 'perl', 'both'), default='python')
    parser.add_argument('--perl', default=shutil.which('perl'))
    parser.add_argument('--saspy-cfgname', default='oda')
    parser.add_argument('--saspy-cfgfile')
    parser.add_argument('--out', type=Path)
    args = parser.parse_args(argv)
    source = ROOT/'tests/macroparas_gtex_regression.sas'
    original_cwd = Path.cwd()
    os.chdir(ROOT)
    try:
        plan = Plan(source.read_text(encoding='utf-8'), source)
    finally:
        os.chdir(original_cwd)
    utility = ROOT/'examples/sas_macros/macroparas_portable.sas'
    assert utility.resolve() in plan.texts, 'Portable macro source must be discovered for upload'
    assert not plan.analysis['findings'], plan.analysis['findings']
    assert '%abort' not in utility.read_text().lower()
    print('PASS: regression source, portable include and offline submission plan verified', flush=True)
    if not args.live:
        print('LIVE SAS TESTS NOT RUN: pass --live with an explicitly configured SAS target.')
        return 0
    output = args.out or ROOT/('SAS_Output_macroparas_regression_'+str(time.time_ns()))
    output.mkdir(parents=True, exist_ok=False)
    results = []
    for runtime in (('python', 'perl') if args.runner == 'both' else (args.runner,)):
        interpreter = sys.executable if runtime == 'python' else args.perl
        if not interpreter:
            raise ValueError('Supply --perl for the Perl test')
        target = output/runtime
        command = [interpreter, (ROOT/('run_sas_codes_or_files_in_ODA.'+('py' if runtime == 'python' else 'pl'))).as_posix(),
                   '--file', source.as_posix(), '--output-prefix', target.as_posix(),
                   '--saspy-cfgname', args.saspy_cfgname, '--skip-sas-oda-auth-bootstrap',
                   '--no-open-html', '--run-timeout-seconds', '120']
        if args.saspy_cfgfile:
            command += ['--saspy-cfgfile', str(Path(args.saspy_cfgfile).resolve())]
        env = dict(os.environ, OPEN_RESULT='0', SAS_ODA_AUTOLOAD_MACROS='0',
                   PIPELINE_PYTHON_BIN=Path(sys.executable).as_posix())
        start = time.monotonic()
        with (output/(runtime+'.stdout.txt')).open('w', encoding='utf-8') as stdout, (output/(runtime+'.stderr.txt')).open('w', encoding='utf-8') as stderr:
            process = subprocess.run(command, cwd=ROOT, env=env, stdout=stdout, stderr=stderr, timeout=180)
        log = (target/'output.html.info.txt').read_text(encoding='utf-8', errors='replace')
        actual = set(re.findall(r'^MACROPARAS_TEST_PASS=(\w+)\s*$', log, re.M))
        errors = re.findall(r'^\s*ERROR[^\r\n]*', log, re.M)
        record = dict(runtime=runtime, target=args.saspy_cfgname, exit_code=process.returncode,
                      seconds=round(time.monotonic()-start, 3), expected=sorted(EXPECTED),
                      passed=sorted(actual), errors=errors,
                      source_sha256=hashlib.sha256(source.read_bytes()).hexdigest(),
                      macro_sha256=hashlib.sha256(utility.read_bytes()).hexdigest())
        record['success'] = process.returncode == 0 and actual == EXPECTED and not errors
        results.append(record)
        (output/'execution.json').write_text(json.dumps(results, indent=2)+'\n', encoding='utf-8')
        print(json.dumps(record), flush=True)
    return 0 if all(item['success'] for item in results) else 1


if __name__ == '__main__':
    raise SystemExit(main())
