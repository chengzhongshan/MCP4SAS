"""Build and validate the pinned COVID19 macro corpus without Perl or SAS."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import subprocess
from . import source_analysis as sa

ROOT=Path(__file__).resolve().parents[1]

def validate_corpus(path=None):
    data=json.loads(Path(path or ROOT/'tests/covid19_gwas_validation_corpus.json').read_text(encoding='utf-8'))
    if data['generated_task_count']!=500 or len(data['tasks'])!=500:
        raise ValueError('Expected 500 tasks')
    for number,task in enumerate(data['tasks'],1):
        source=task['source']
        kind=task['kind']
        if kind=='include':
            ok=sa.include_targets(source)==task['targets']
        elif kind=='declaration':
            ok=not sa.analyze_source(source)['findings'] and re.search(r'%macro\s+'+re.escape(task['name'])+r'\b',sa.macro_dependency_view(source),re.I)
        elif kind=='invocation':
            ok=re.search('%'+re.escape(task['name'])+r'\b',sa.macro_dependency_view(source),re.I) and not sa.include_targets(source)
        elif kind=='prx_boundary':
            ok=not any(item['type']=='unexpected_comment_close' for item in sa.analyze_source(source)['findings'])
        elif kind=='demo':
            ok=(hashlib.sha256(source.encode()).hexdigest()==task['sha256']
                and [f['type'] for f in sa.analyze_source(source)['findings']]==task['finding_types']
                and sa.include_targets(source)==task['targets']
                and len(re.findall(r'%([A-Za-z_][A-Za-z0-9_]*)',sa.macro_dependency_view(source)))==task['macro_token_count'])
        else:
            raise ValueError(f'Unknown corpus category: {kind}')
        if not ok:
            raise AssertionError(f'C{number:03d}: {kind} [{task["path"]}]')
    return len(data['tasks'])

def build(root,source_commit=None):
    root=Path(root).resolve(strict=True)
    commit=subprocess.check_output(['git','-C',str(root),'rev-parse',source_commit or 'HEAD'],text=True).strip()
    # Git objects make the requested revision independent of worktree line endings
    # and prevent accidental use of unrelated local edits in a pinned manifest.
    names=subprocess.check_output(['git','-C',str(root),'ls-tree','-r','--name-only',commit],text=True).splitlines()
    definitions=[]; includes=[]; prx=[]; demos=[]; seen=set()
    for name in sorted(n for n in names if n.lower().endswith('.sas')):
        source=subprocess.check_output(['git','-C',str(root),'show',f'{commit}:{name}']).decode('utf-8',errors='replace')
        for number,line in enumerate(source.splitlines(keepends=True),1):
            match=re.match(r'\s*%macro\s+([A-Za-z_]\w*)',line,re.I)
            if match and match[1].lower() not in seen:
                seen.add(match[1].lower())
                definitions.append(dict(name=match[1],path=name,line=number,evidence=line))
            if re.search(r'%include\b',line,re.I):
                includes.append(dict(path=name,line=number,source=line,targets=sa.include_targets(line)))
            if not re.match(r'\s*/\*',line) and re.search(r'prx(?:match|change)\s*\(\s*(?:s)?/.*\*/',line,re.I):
                if not any(f['type']=='unexpected_comment_close' for f in sa.analyze_source(line)['findings']):
                    prx.append(dict(path=name,line=number,source=line))
        if not name.startswith('Macros/'):
            demos.append(dict(path=name,source=source,sha256=hashlib.sha256(source.encode()).hexdigest(),
                              finding_types=[f['type'] for f in sa.analyze_source(source)['findings']],
                              targets=sa.include_targets(source),macro_token_count=len(re.findall(r'%([A-Za-z_]\w*)',sa.macro_dependency_view(source)))))
    if len(definitions)<200 or len(includes)<86 or len(prx)!=7 or len(demos)!=7:
        raise ValueError(f'Pinned corpus requires >=200 definitions, >=86 includes, 7 PRX cases and 7 demos; found {len(definitions)}, {len(includes)}, {len(prx)}, {len(demos)}')
    tasks=[dict(kind='declaration',**d,source=f'%macro {d["name"]}();\n%mend {d["name"]};\n') for d in definitions[:200]]
    tasks += [dict(kind='invocation',name=d['name'],path=d['path'],line=d['line'],source=f'%{d["name"]}();\n') for d in definitions[:200]]
    tasks += [dict(kind=kind,**item) for kind,items in [('include',includes[:86]),('prx_boundary',prx),('demo',demos)] for item in items]
    return dict(source_repository='https://github.com/chengzhongshan/COVID19_GWAS_Analyzer',source_commit=commit,
                generated_task_count=len(tasks),categories=dict(Counter(t['kind'] for t in tasks)),tasks=tasks)

def build_main(argv=None):
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('root'); parser.add_argument('output',nargs='?',default='tests/covid19_gwas_validation_corpus.python.json')
    parser.add_argument('--source-commit')
    args=parser.parse_args(argv)
    output=Path(args.output)
    data=build(args.root,args.source_commit)
    # Refuse to replace an existing manifest without an explicit filesystem edit.
    with output.open('x',encoding='utf-8') as stream:
        json.dump(data,stream,ensure_ascii=False,indent=2);stream.write('\n')
    print(f'Wrote {len(data["tasks"])} source-versioned tasks to {output}')
    return 0

def validate_main():
    parser=argparse.ArgumentParser(description='Run the original 500 source-provenanced parser checks in Python; no SAS connection.')
    parser.add_argument('--manifest')
    args=parser.parse_args()
    print(f'PASS: {validate_corpus(args.manifest)} original corpus checks')
    return 0
