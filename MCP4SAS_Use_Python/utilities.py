"""Python source profiler and streaming GTEx matrix subsetter."""
import argparse
import gzip
import hashlib
import json
import os
from pathlib import Path
import platform
import re
import statistics
import sys
import tempfile
import time
from . import source_analysis
from .dependencies import read_source

def profile_main(argv=None):
    parser=argparse.ArgumentParser(description='Profile local SAS source analysis; no SAS connection.')
    parser.add_argument('--repeat',type=int,default=3)
    parser.add_argument('--output')
    parser.add_argument('files',nargs='+')
    args=parser.parse_args(argv)
    if not 1<=args.repeat<=100:
        parser.error('--repeat must be between 1 and 100')
    files=[]
    for file in args.files:
        text=read_source(file)
        measurements=[]
        for name in ('analyze_source','macro_dependency_view','include_targets'):
            seconds=[]
            hashes=[]
            for _ in range(args.repeat):
                start=time.perf_counter()
                result=getattr(source_analysis,name)(text)
                seconds.append(time.perf_counter()-start)
                encoded=result if isinstance(result,str) else json.dumps(result,sort_keys=True,separators=(',',':'),ensure_ascii=False)
                hashes.append(hashlib.sha256(encoded.encode('utf-8')).hexdigest())
            if len(set(hashes))!=1:
                raise RuntimeError(f'Unstable {name} result for {file}')
            measurements.append(dict(operation=name,seconds=seconds,median_seconds=statistics.median(seconds),result_sha256=hashes[0]))
        files.append(dict(file=file,source_bytes=Path(file).stat().st_size,source_sha256=hashlib.sha256(Path(file).read_bytes()).hexdigest(),measurements=measurements))
    report=dict(scope='Local Python source inspection; excludes hashing, SAS execution, network and model requests.',python_version=platform.python_version(),platform=sys.platform,repeat=args.repeat,files=files)
    text=json.dumps(report,indent=2)+'\n'
    if args.output:
        Path(args.output).write_text(text,encoding='utf-8')
    else:
        print(text,end='')
    return 0

def subset_expression(input_file,genes,output_file):
    output=Path(output_file)
    if output.exists():
        raise FileExistsError(f'Output already exists: {output}')
    wanted={name.upper():0 for name in re.split(r'[\s,]+',genes) if name}
    if not wanted:
        raise ValueError('No gene symbols specified')
    open_input=gzip.open if str(input_file).lower().endswith('.gz') else open
    fd,temporary=tempfile.mkstemp(prefix='.gtex-subset-',dir=output.parent)
    temporary=Path(temporary)
    try:
        with os.fdopen(fd,'wb') as target,open_input(input_file,'rb') as source:
            header=source.readline()
            if not header:
                raise ValueError('Empty input matrix')
            columns=header.rstrip(b'\r\n').split(b'\t')
            if len(columns)<2:
                raise ValueError('Matrix must be tab-delimited with sample columns')
            target.write(header)
            read,kept=0,0
            for line in source:
                read+=1
                symbol=line.split(b'\t',1)[0].split(b'|')[-1].decode('utf-8').upper()
                if symbol not in wanted:
                    continue
                if len(line.rstrip(b'\r\n').split(b'\t'))!=len(columns):
                    raise ValueError(f'Ragged selected matrix row {read} for {symbol}')
                target.write(line)
                wanted[symbol]+=1
                kept+=1
            missing=sorted(key for key,count in wanted.items() if not count)
            if missing:
                raise ValueError('Missing requested genes: '+' '.join(missing))
        # Same-directory hard link is atomic and refuses concurrent overwrites.
        os.link(temporary,output)
        return dict(read=read,kept=kept,output=str(output))
    finally:
        temporary.unlink(missing_ok=True)

def subset_main(argv=None):
    parser=argparse.ArgumentParser(description='Stream a plain/gzipped gene-expression matrix without changing the input.')
    for name in ('input','genes','output'):
        parser.add_argument('--'+name,required=True)
    args=parser.parse_args(argv)
    result=subset_expression(args.input,args.genes,args.output)
    print(f"Read {result['read']} matrix rows; retained {result['kept']} matching rows in {result['output']}. Input unchanged.")
    return 0
