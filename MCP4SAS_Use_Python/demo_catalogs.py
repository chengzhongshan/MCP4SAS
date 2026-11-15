"""Original, source-hashed SAS example catalogs with native Python generation."""
import argparse
import copy
import hashlib
import json
from pathlib import Path
import re
import secrets

ROOT=Path(__file__).resolve().parents[1]
ASSETS=Path(__file__).parent/'assets'

def fingerprint(source):
    source=re.sub(r'\be\d+','eCASE',source,flags=re.I)
    source=re.sub(r'MCP30_(OK|ASSERT)_\d+',r'MCP30_\1_CASE',source)
    return hashlib.sha256(re.sub(r'\s+',' ',source).encode()).hexdigest()

def catalog(batch):
    if not 1<=batch<=8:
        raise ValueError('Batch must be 1 through 8')
    data=json.loads((ASSETS/'example_catalogs.json').read_text(encoding='utf-8'))
    previous=set()
    for number,items in enumerate(data['batches'][:batch],1):
        seen=set()
        ids=set()
        for item in items:
            digest=fingerprint(item['sas'])
            if digest in previous or digest in seen or item['id'] in ids:
                raise ValueError(f'Duplicate example in batch {number}: {item["id"]}')
            seen.add(digest)
            ids.add(item['id'])
        previous.update(seen)
    return copy.deepcopy(data['batches'][batch-1])

def generate(batch,out,library_root=None):
    cases=catalog(batch)
    out=Path(out).resolve()
    out.mkdir(parents=True,exist_ok=False)
    provenance=json.loads((ROOT/'tests/sas_library_source_manifest.json').read_text(encoding='utf-8'))
    for case in cases:
        ref=case.get('source_ref')
        if ref:
            record=provenance[ref]
            collection,filename=ref.split(':',1)
            collection={'E':'Easy-For-Error-Codes-SAS','D':'SAS_Code_Database'}[collection]
            case.update(source_collection=collection,source_file=filename,source_sha256=record['sha256'])
            if library_root:
                path=Path(library_root)/collection/filename
                if hashlib.sha256(path.read_bytes()).hexdigest()!=record['sha256']:
                    raise ValueError(f'Library source changed: {path}')
        fixtures=case.get('fixtures',[]) or ([case['fixture']] if 'fixture' in case else [])
        paths=[]
        for index,body in enumerate(fixtures,1):
            path=out/f'include_{case["id"]}_{index}_{secrets.token_hex(6)}.sas'
            path.write_text(body,encoding='utf-8')
            token=f'@FIXTURE_{index}@' if case.get('fixtures') else '@FIXTURE@'
            case['sas']=case['sas'].replace(token,path.as_posix())
            paths.append(str(path))
        case['fixture_paths']=paths
        path=out/f'{case["id"]}_{case["name"]}.sas'
        path.write_text('options notes nosyntaxcheck obs=max; ods select all; title; footnote;\n'+case['sas'],encoding='utf-8')
        case['path']=str(path)
    (out/'catalog.json').write_text(json.dumps(cases,indent=2)+'\n',encoding='utf-8')
    return cases

def catalog_main(batch):
    parser=argparse.ArgumentParser(description=f'Inspect or generate original SAS example batch {batch}; no Perl or SAS required.')
    parser.add_argument('--out')
    args=parser.parse_args()
    if args.out:
        cases=generate(batch,args.out)
        print(f'Generated {len(cases)} original cases in {Path(args.out).resolve()}')
    else:
        print(json.dumps(catalog(batch),indent=2))
    return 0
