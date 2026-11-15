"""Native checks for the original executable SAS case collections."""
import json
from pathlib import Path
from .evaluation import select_cases,checked_source,behavior_fingerprint,contract_fingerprint
from .source_analysis import analyze_source,include_targets,open_code_macro_issues

ROOT=Path(__file__).resolve().parents[1]
COLLECTIONS=['library500',*('library500_round'+str(i) for i in range(2,9)),
             'macro_open_code50','library500_round10']


def verify(name):
    directory=ROOT/'tests'/name
    manifest=json.loads((directory/'manifest.json').read_text(encoding='utf-8'))
    cases=select_cases(manifest)
    fingerprints=set();families={};negative=0;warnings=0
    for prior in COLLECTIONS[:COLLECTIONS.index(name)]:
        folder=ROOT/'tests'/prior
        for case in json.loads((folder/'manifest.json').read_text(encoding='utf-8'))['cases']:
            fingerprints.add(behavior_fingerprint(case,(folder/case['file']).read_text(encoding='utf-8')))
    for case in cases:
        source=(directory/case['file']).read_bytes().decode('utf-8')
        checked_source(case,source)
        fingerprint=behavior_fingerprint(case,source)
        assert fingerprint not in fingerprints,case['id']+' duplicates normalized executable behavior'
        fingerprints.add(fingerprint)
        assert not analyze_source(source)['findings'],case['id']+' has unbalanced lexical source'
        assert not include_targets(source),case['id']+' unexpectedly depends on an include'
        assert len(contract_fingerprint(case))==64
        families[case['family']]=families.get(case['family'],0)+1
        if case.get('expected_failure'):
            negative+=1
            assert not __import__('re').search(r'(?:LIB500|ROUND\d+)_PASS=',source),case['id']+' negative has a success marker'
        else:
            assert case['id'] in source,case['id']+' lacks own marker'
        warnings+=bool(case.get('warning_pattern'))
        evidence=case.get('evidence',{})
        assert len(evidence.get('source_sha256',''))==64,case['id']+' lacks original source fingerprint'
        if name=='macro_open_code50':
            found={v['type'] for v in open_code_macro_issues(source)}
            assert set(case['expected_lint'])<=found,case['id']+' missing expected structural finding'
            if not case['expected_lint'] and not case.get('expected_failure'):
                assert not found,case['id']+' falsely flagged as structural error'
    if name=='macro_open_code50':
        assert len(cases)==50 and negative==20 and warnings==5
    else:
        assert len(cases)==500 and len(families)==50 and set(families.values())=={10}
    print(f'{name}: {len(cases)} source/oracle contracts checked; {negative} intentional errors; NOT a live SAS execution')
    return 0
