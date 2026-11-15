"""Check hashes, provenance, input bytes, and duplication without SAS access."""
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import sys

ROOT=Path(__file__).resolve().parents[1]
COLLECTIONS=('library_workflows500','online_samples500')

def sha(raw):return hashlib.sha256(raw).hexdigest()
def normalized(text):
    text=re.sub(r'/\*.*?\*/','',text,flags=re.S)
    # Normalize identifiers and completion protocols used by old and new catalogs.
    text=re.sub(r'\b[A-Z]\d{3,5}(?=[A-Za-z_\b]|\b)','CASE',text,flags=re.I)
    text=re.sub(r'\b(?:ROUND\d+|LIB500|NEW_WORKFLOW)_(?:DONE|PASS|OUT)\b','RESULT',text)
    return re.sub(r'\s+',' ',text).strip()

def main():
    prior={};new={};records=[];failures=[]
    for path in (ROOT/'tests').rglob('*.sas'):
        if any(name in path.parts for name in COLLECTIONS):continue
        key=sha(normalized(path.read_text(encoding='utf-8-sig',errors='replace')).encode())
        prior.setdefault(key,[]).append(path.relative_to(ROOT).as_posix())
    for name in COLLECTIONS:
        root=ROOT/'tests'/name;manifest=json.loads((root/'manifest.json').read_text())
        assert len(manifest['cases'])==500
        families=Counter(c['family'] for c in manifest['cases']);assert len(families)==25
        for c in manifest['cases']:
            raw=(root/c['file']).read_bytes();assert sha(raw)==c['sha256'],c['id']
            key=sha(normalized(raw.decode()).encode())
            if key in new or key in prior:failures.append(dict(id=c['id'],duplicate=new.get(key,prior.get(key))))
            new[key]=c['id']
            assert c['expected'],c['id']
        sources={}
        for macro in manifest['macro_snapshots']:
            assert sha((root/'macros'/macro['snapshot']).read_bytes())==macro['snapshot_sha256']
            sources[macro['file']]=macro['source_sha256']
        for c in manifest['cases']:
            if 'evidence' in c:sources[c['evidence']['file']]=c['evidence']['sha256']
        # Original H: sources are optional on another computer. When present,
        # verify that testing did not modify a single source byte.
        present=0
        for file,digest in sources.items():
            source=Path(manifest['source_root'])/file
            if source.is_file():assert sha(source.read_bytes())==digest,file;present+=1
        inputs=[dict(file=p.relative_to(ROOT).as_posix(),sha256=sha(p.read_bytes()),bytes=p.stat().st_size)
                for p in sorted((root/'inputs').glob('*'))]
        records.append(dict(collection=name,cases=500,families=dict(families),metrics=sum(len(c['expected']) for c in manifest['cases']),
            manifest_sha256=sha((root/'manifest.json').read_bytes()),original_files=len(sources),original_hashes_verified=present,inputs=inputs))
    result=dict(prior_sas_files=sum(map(len,prior.values())),prior_unique_programs=len(prior),
                new_unique_programs=len(new),duplicates=failures,collections=records)
    (ROOT/'docs/NEW_WORKFLOW_SOURCE_AUDIT.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(json.dumps({k:v for k,v in result.items() if k!='collections'}))
    return bool(failures)

if __name__=='__main__':raise SystemExit(main())
