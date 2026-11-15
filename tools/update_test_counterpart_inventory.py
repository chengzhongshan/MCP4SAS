#!/usr/bin/env python3
"""Update the extended test-port inventory without regenerating runtime assets."""
import csv
import hashlib
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]


def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    mapping=[]
    for source in sorted((ROOT/'tests').glob('*.pl')):
        target=source.with_suffix('.py')
        if not target.is_file():raise ValueError('Missing Python counterpart '+source.name)
        text=target.read_text(encoding='utf-8')
        kind=('frozen_reference_replay' if 'regression_replay' in text else
              'focused_native_tests' if 'run_selected' in text else
              'original_SAS_corpus_checks' if 'corpus_regression' in text else
              'native_functional_or_catalog_entry')
        mapping.append(dict(perl_script=source.relative_to(ROOT).as_posix(),perl_sha256=digest(source),
            python_counterpart=target.relative_to(ROOT).as_posix(),python_sha256=digest(target),coverage_kind=kind))
    destination=ROOT/'docs/TEST_COUNTERPART_MAP.csv'
    with destination.open('w',encoding='utf-8',newline='') as handle:
        writer=csv.DictWriter(handle,fieldnames=list(mapping[0]));writer.writeheader();writer.writerows(mapping)
    path=ROOT/'MCP4SAS_Use_Python/PORT_INVENTORY.csv'
    with path.open(encoding='utf-8',newline='') as handle:
        reader=csv.DictReader(handle);fields=reader.fieldnames;rows=list(reader)
    known={row['source'] for row in rows}
    targets={row['perl_script']:row['python_counterpart'] for row in mapping}
    targets.update({'MCPDeps/SAS_Evaluation_Corpus.pm':'MCP4SAS_Use_Python/evaluation.py',
                    'MCPDeps/SAS_Evaluation_Log.pm':'MCP4SAS_Use_Python/evaluation.py',
                    'tools/collect_library_evaluation_results.pl':'tools/collect_library_evaluation_results.py'})
    for source,target in targets.items():
        if source not in known:
            file=ROOT/source
            rows.append(dict(source=source,source_sha256=digest(file),bytes=file.stat().st_size,scope='',python_target='',status=''))
    for row in rows:
        if row['source'] in targets:
            row.update(python_target=targets[row['source']],status='implemented',scope='extended_regression' if row['source'].startswith('tests/') else 'runtime_or_utility')
    with path.open('w',encoding='utf-8',newline='') as handle:
        writer=csv.DictWriter(handle,fieldnames=fields);writer.writeheader();writer.writerows(sorted(rows,key=lambda v:v['source']))
    # Keep the earlier baseline attribution; refresh current launcher hashes only.
    path=ROOT/'MCP4SAS_Use_Python/HOMEPAGE_DEMO_MANIFEST.json'
    manifest=json.loads(path.read_text(encoding='utf-8'))
    for row in manifest['entry_points']:
        row['python_sha256']=digest(ROOT/row['python'])
    path.write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
    print(f'{len(mapping)} root Perl scripts have Python counterparts; historical baseline hashes retained in port inventory')
    return 0


if __name__=='__main__':raise SystemExit(main())
