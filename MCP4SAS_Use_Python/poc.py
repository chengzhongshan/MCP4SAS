"""PoC execution and independent numeric validation, without Perl or AI calls."""
import argparse
import csv
from datetime import datetime
import json
import math
from pathlib import Path
import re
import struct
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[1]
EXAMPLES=ROOT/'examples/poc'

def case_for(identifier):
    manifest=json.loads((EXAMPLES/'manifest.json').read_text(encoding='utf-8'))
    for case in manifest['cases']:
        if case['id']==identifier:
            return case
    raise ValueError(f'Unknown case {identifier}; use --list')

def table(path,delimiter=','):
    with Path(path).open(encoding='utf-8-sig',newline='') as handle:
        reader=csv.reader(handle,delimiter=delimiter,strict=True)
        header=next(reader)
        if len({value.lower() for value in header})!=len(header):
            raise ValueError('Duplicate CSV columns')
        rows=[]
        for row in reader:
            if len(row)!=len(header):
                raise ValueError('CSV column mismatch')
            rows.append(dict(zip([key.lower() for key in header],row)))
        return rows

def near(a,b):
    try:
        a,b=float(a),float(b)
        return math.isfinite(a) and math.isfinite(b) and abs(a-b)<=1e-10*max(1,abs(a),abs(b))
    except (ValueError,TypeError):
        return False

def validate(identifier,directory):
    case=case_for(identifier)
    directory=Path(directory)
    count=0
    def check(value,message):
        nonlocal count
        if not value:
            raise ValueError('FAIL: '+message)
        count+=1
    tables={}
    for name in case['files']:
        if not re.fullmatch(r'[A-Za-z0-9_.-]+(?:/[A-Za-z0-9_.-]+)*',name) or any(part in ('.','..') for part in Path(name).parts):
            raise ValueError('Invalid manifest output path')
        path=directory/name
        check(path.is_file() and path.stat().st_size>0,'nonempty '+name)
        if name.endswith('.csv'):
            tables[name]=table(path)
            check(len(tables[name])==case['expected_csv_rows'][name],name+' expected row count')
        elif name.endswith('.png'):
            data=path.read_bytes()
            check(data[:8]==b'\x89PNG\r\n\x1a\n' and len(data)>24,name+' PNG signature')
            w,h=struct.unpack('>II',data[16:24])
            check(w>0 and h>0,name+' dimensions')
        elif name.endswith('.svg'):
            check(re.search(r'<svg\b',path.read_text(encoding='utf-8')) is not None,name+' SVG root')
    if identifier=='hello':
        check(len({row['name'] for row in tables['hello.csv']})==19,'19 distinct SASHELP.CLASS records')
    elif identifier=='clustergram':
        source=table(EXAMPLES/'inputs/poc261112_expression40.tsv','\t')
        scaled={row['gene']:row for row in tables['clustergram_2.csv']}
        check(len(source)==len(scaled)==40,'40 genes')
        for row in source:
            tissues=sorted(key for key in row if key!='gene')
            check(len(tissues)==10,'ten tissues per gene')
            values=[math.log2(1+float(row[key])) for key in tissues]
            mean=sum(values)/10
            sd=math.sqrt(sum((v-mean)**2 for v in values)/9)
            check(sd>0,'nonconstant gene profile')
            for key,value in zip(tissues,values):
                check(near(scaled[row['gene']][key],(value-mean)/sd),'independent log2/sample-SD standardization')
    elif identifier=='gene_gtf':
        check(len({r['ensembl_transcript'] for r in tables['gene_gtf_0.csv'] if r.get('ensembl_transcript')})==3,'three transcript identifiers')
        for row in tables['gene_gtf_1.csv']:
            check(float(row['chr'])==2 and 72350000<=float(row['bp'])<=72380000 and 0<float(row['p'])<=1,'GRCh37 region and P range')
    elif identifier=='oncoprint':
        tiles=tables['oncoprint_0.csv']
        callable_rows=[r for r in tiles if float(r['callable'])==1]
        check(len(tiles)==96 and len(callable_rows)==94,'96 pairs and 94 assessable pairs')
        check(sum(float(r['n_variants']) for r in tiles)==64,'64 synthetic events')
        check(sum(float(r['n_events']) for r in tables['oncoprint_2.csv'])==64,'event-burden total')
        for row in tables['oncoprint_1.csv']:
            gene=[r for r in callable_rows if r['gene']==row['gene']]
            mutated=[r for r in gene if float(r['n_variants'])>0]
            check(len(gene)==float(row['n_callable']) and len(mutated)==float(row['n_mutated']) and near(100*len(mutated)/len(gene),row['pct_mutated']),'assessable denominator and unique mutated pairs')
    elif identifier=='forest':
        for row in tables['forest_0.csv']:
            check(near(row['beta'],math.log(float(row['odds_ratio']))) and near(row['se'],(math.log(float(row['upper']))-math.log(float(row['lower'])))/3.92),'log OR and approximate SE from rounded limits')
    elif identifier=='multi_gwas_gtf':
        check(sum(r['ld_r2'] in ('','.') for r in tables['regional_input.csv'])==10,'ten missing LD estimates')
        for row in tables['panel_values.csv']:
            p=float(row['p'])
            check(0<p<=1 and near(row['neglog10p'],-math.log10(p)),'association height')
            if row['ld_r2'] in ('','.'):
                check(row['signed_ld'] in ('','.'),'missing LD retained')
            else:
                z=float(row['z'])
                check(near(row['signed_ld'],float(row['ld_r2'])*((z>0)-(z<0))),'signed LD arithmetic')
    print(f'PASS: {count} file, row-count and numerical checks for {identifier}.')
    print('Inspect the complete SAS log and figure appearance separately; this is not full scientific validation.')
    return count

def validate_main(argv=None):
    parser=argparse.ArgumentParser()
    parser.add_argument('--case',required=True)
    parser.add_argument('--dir',required=True)
    args=parser.parse_args(argv)
    validate(args.case,args.dir)
    return 0

def run_main(argv=None):
    parser=argparse.ArgumentParser(description='Run the existing scientific PoC programs with the Python runtime.')
    parser.add_argument('--case')
    parser.add_argument('--outdir')
    parser.add_argument('--session-id',default='poc_showcase_python')
    parser.add_argument('--list',action='store_true')
    parser.add_argument('--dry-run',action='store_true')
    parser.add_argument('--saspy-cfgname')
    parser.add_argument('--saspy-cfgfile')
    args=parser.parse_args(argv)
    if args.list:
        for case in json.loads((EXAMPLES/'manifest.json').read_text())['cases']:
            print(case['id']+'\t'+case['program'])
        return 0
    case=case_for(args.case)
    if not re.fullmatch(r'[A-Za-z0-9_-]+',args.session_id):
        raise ValueError('Invalid session ID')
    outdir=Path(args.outdir or ROOT/('SAS_Output_PoC_Python_'+args.case+'_'+datetime.now().strftime('%Y%m%d_%H%M%S'))).resolve()
    if outdir.exists() and not args.dry_run:
        raise FileExistsError('Output directory already exists')
    common=[sys.executable,str(ROOT/'run_sas_codes_or_files_in_ODA.py'),'--persistent','--session-id',args.session_id,'--run-timeout-seconds','600']
    for key in ('saspy_cfgname','saspy_cfgfile'):
        if getattr(args,key):
            common+=['--'+key.replace('_','-'),getattr(args,key)]
    submit=common+['--file',str(EXAMPLES/case['program']),'--output-prefix',str(outdir/'submit')]
    for item in case['inputs']:
        submit+=['--upload-file',str(EXAMPLES/item['file'])]
    if args.dry_run:
        print(json.dumps(dict(case=args.case,session_id=args.session_id,submit_argv=submit,collect_files=case['files'],outdir=str(outdir),note='Plan only; no upload or SAS connection.'),indent=2))
        return 0
    import os
    env=dict(os.environ,SAS_ODA_AUTOLOAD_MACROS='0',OPEN_RESULT='0')
    subprocess.run(submit,check=True,env=env)
    log=(outdir/'submit/output.html.info.txt').read_text(encoding='utf-8')
    if re.search(r'^\s*ERROR(?:\s+\d+-\d+)?:',log,re.M):
        raise ValueError('SAS log contains errors')
    if not re.search(r'^'+re.escape(case['completion_marker'])+r'\s*$',log,re.M):
        raise ValueError('Missing completion marker')
    remote=re.search(r'^POC_OUT=([^\r\n]+)',log,re.M)
    if not remote:
        raise ValueError('Missing WORK output path')
    files=outdir/'files'
    collect=common+['--output-prefix',str(outdir/'collect')]
    for name in case['files']:
        if any(p in ('.','..') for p in Path(name).parts):
            raise ValueError('Unsafe output path')
        collect+=['--download-file',remote[1].rstrip()+'/'+name,'--download-local-path',str(files/name)]
    subprocess.run(collect,check=True,env=env)
    count=validate(args.case,files)
    (outdir/'run.json').write_text(json.dumps(dict(case=args.case,session_id=args.session_id,checks=count,warnings=re.findall(r'^WARNING:[^\r\n]*',log,re.M),scope='Saved SAS-program execution and numerical checks; no AI trial or token benchmark.'),indent=2),encoding='utf-8')
    print('Example collected and checked: '+str(files))
    return 0
