"""Replay captured Perl test inputs through native Python source analysis."""
import hashlib
import json
from pathlib import Path
from . import source_analysis


def main(name):
    root=Path(__file__).resolve().parents[1]
    fixture=json.loads((Path(__file__).parent/'assets/remaining_regressions.json').read_text(encoding='utf-8'))[name]
    if hashlib.sha256((root/fixture['source_file']).read_bytes()).hexdigest()!=fixture['source_sha256']:
        raise ValueError('Perl reference test changed; review and regenerate the frozen vectors')
    failures=[]
    for index,case in enumerate(fixture['calls']):
        function=getattr(source_analysis,case['function'])
        try:
            actual=function(*case['arguments'])
            expected=case['result']
            if case['function'] in ('is_builtin_macro_name','is_local_file_candidate','include_target_needs_runtime_resolution'):
                actual,expected=bool(actual),bool(expected)
            if case['list_context']:actual=[actual]
            if actual!=expected:
                failures.append(dict(index=index,function=case['function'],actual=actual,expected=expected,arguments=case['arguments']))
        except Exception as exc:failures.append(dict(index=index,function=case['function'],exception=str(exc)))
    if failures:
        out=root/'MCP4SAS_Use_Python/test-results/remaining-parity';out.mkdir(parents=True,exist_ok=True)
        (out/(name+'.json')).write_text(json.dumps(failures,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
    print(f'{name}: {len(fixture["calls"])-len(failures)}/{len(fixture["calls"])} native API vectors passed')
    return int(bool(failures))
