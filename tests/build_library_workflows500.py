"""Build 500 new, vector-checked workflows from the author's actual macros.

Reads the original library without changing it. Namespaced definition snapshots
avoid overwriting the author's ordinary macro files on SAS ODA.
"""
import csv
import gzip
import hashlib
import io
import json
import math
from pathlib import Path
import random
import re
import statistics
import sys
import zipfile

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
from MCP4SAS_Use_Python.source_analysis import mask_comments, mask_noncode

LIBRARY = Path('H:/F_Queens/360yunpan/SASCodesLibrary/SAS-Useful-Codes/Macros')
DEST = ROOT / 'tests/library_workflows500'
PREFIX = 'n26_'


def sha(data):
    return hashlib.sha256(data).hexdigest()


def literal(value):
    if value is None:
        return '.'
    if isinstance(value, str):
        return "'" + value.replace("'", "''") + "'"
    return repr(value)


def data_step(name, columns, rows):
    # Assignment-based fixtures can contain quotes and delimiters without
    # relying on the SAS importer that is being tested.
    char = ' '.join(f'{key} $80' for key, kind in columns if kind == 'char')
    text = f'data {name};\n' + (f'length {char};\n' if char else '')
    for row in rows:
        text += ';'.join(f'{key}={literal(value)}' for (key, _), value in zip(columns, row)) + ';output;\n'
    return text + 'run;\n'


def flatten(table, columns, key='gene', metric_table='metrics'):
    variables = ' '.join(columns)
    return (f'data {metric_table}(keep=metric value);set {table};length metric $120;'
            f'array measured[*] {variables};do _measure=1 to dim(measured);'
            f"metric=catx(':',strip({key}),vname(measured[_measure]));"
            'value=measured[_measure];output;end;run;\n')


def expected_rows(rows, columns):
    return {f'{row[0]}:{col}': value for row in rows for col, value in zip(columns, row[1:])}


def definitions(text):
    view = mask_comments(text)
    active = mask_noncode(text)
    tokens = list(re.finditer(r'%(macro|mend)\b([^;]*);', active, re.I))
    depth = 0
    start = None
    result = []
    for token in tokens:
        if token[1].lower() == 'macro':
            if depth == 0:
                start = token.start()
            depth += 1
        else:
            depth -= 1
            if depth == 0 and start is not None:
                result.append((text[start:token.end()], start))
    if depth or not result:
        raise ValueError('Unbalanced or absent macro definition')
    return result


class Snapshot:
    def definitions(self,text):
        return definitions(text)

    def __init__(self, destination, source_root=LIBRARY):
        self.directory = destination / 'macros'
        self.directory.mkdir(parents=True, exist_ok=True)
        self.root = source_root
        self.records = {}
        self.files = {p.stem.casefold(): p for p in source_root.glob('*.sas')}

    def add(self, name):
        key = name.casefold()
        if key in self.records:
            return PREFIX + name
        source = self.files.get(key)
        if source is None:
            raise FileNotFoundError('Macro source not found: ' + name)
        raw = source.read_bytes()
        text = raw.decode('utf-8-sig', errors='replace')
        chunks = self.definitions(text)
        selected_pair = next(((chunk,offset) for chunk, offset in chunks if re.match(r'%macro\s+' + re.escape(name) + r'\b', chunk, re.I)), None)
        selected = selected_pair[0] if selected_pair else None
        if selected is None:
            raise ValueError(f'{source.name} does not define %{name}')
        self.records[key] = dict(file=source.name, source_sha256=sha(raw), namespaced=PREFIX+name,
                                 definition_line=1+text[:selected_pair[1]].count('\n'))
        corrections=[]
        if key=='getzipcontents':
            old="dirname=prxchange('s/^(.*)\\/[^\\/]+$/$1/',-1,memname);"
            new="if index(strip(memname),'/') then dirname=prxchange('s/^(.*)\\/[^\\/]+$/$1/',-1,memname); else dirname='.';"
            if old not in selected:raise ValueError('ZIP root-member patch anchor changed')
            selected=selected.replace(old,new)
            corrections.append(dict(reason='Root ZIP members have no directory; use explicit dot sentinel.',before=old,after=new))
        elif key=='importfileheadersfromzip':
            old='%if &filename_rgx eq %then %do;'
            new='%if %length(%superq(filename_rgx))=0 %then %do;'
            if old not in selected:raise ValueError('ZIP regex-parameter patch anchor changed')
            selected=selected.replace(old,new)
            corrections.append(dict(reason='Test regex emptiness without evaluating regex metacharacters as arithmetic.',before=old,after=new))
            old='infile inzip(&txtdir/&txtfilename)'
            new='%if %superq(txtdir)=. %then %do; infile inzip(&txtfilename) %end; %else %do; infile inzip(&txtdir/&txtfilename) %end;'
            if old not in selected:raise ValueError('ZIP member-reader patch anchor changed')
            selected=selected.replace(old,new)
            corrections.append(dict(reason='Read root ZIP member without a nonexistent directory prefix.',before=old,after=new))
        if corrections:self.records[key]['test_copy_corrections']=corrections
        # Discover referenced library macros, including deferred quoted calls.
        names = set(re.findall(r'%([A-Za-z_]\w*)', mask_comments(selected)))
        dependencies = [n for n in sorted(names) if n.casefold() != key and n.casefold() in self.files]
        for dependency in dependencies:
            self.add(dependency)
        rename = {key: PREFIX + name, **{n.casefold(): PREFIX + n for n in dependencies}}
        selected = re.sub(r'%([A-Za-z_]\w*)', lambda m: '%' + rename.get(m[1].casefold(), m[1]), selected)
        selected = re.sub(r'(%(?:macro|mend)\s+)([A-Za-z_]\w*)',
                          lambda m: m[1] + rename.get(m[2].casefold(), m[2]), selected, flags=re.I)
        file = self.directory / (PREFIX + name + '.sas')
        content = f'/* Test-only namespaced definition from {source.name}; original SHA256 {sha(raw)}. */\n' + selected + '\n'
        file.write_text(content, encoding='utf-8',newline='\n')
        self.records[key].update(snapshot=file.name, snapshot_sha256=sha(content.encode()), dependencies=dependencies)
        return PREFIX + name


def normalize_behavior(text):
    text = re.sub(r'/\*.*?\*/', '', text, flags=re.S)
    text = re.sub(r'\b[VW]\d{4}\b', 'CASE', text, flags=re.I)
    text = re.sub(r'\b[vw]\d{4}(?=[A-Za-z_])', 'case', text, flags=re.I)
    return re.sub(r'\s+', ' ', text).strip()


def finish_program(identifier, body):
    return (f'/* New workflow {identifier}; invented deterministic fixtures, not research results. */\n'
            'options notes merror serror;\n' + body +
            f'\ndata {identifier.lower()}m;set {identifier.lower()}m;format value best32.;run;\n'
            f'proc export data={identifier.lower()}m outfile="%sysfunc(pathname(work))/{identifier}.csv" dbms=csv replace;run;\n'
            f'%put NEW_WORKFLOW_DONE={identifier};\n'
            '%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));\n'
            f'proc datasets library=work nolist;delete {identifier.lower()}:;quit;\n')


FAMILIES = [
    'pivot_complete', 'pivot_zero_fill', 'pivot_sentinel_fill',
    'zscore_columns', 'zscore_rows', 'column_type_inventory',
    'keep_regex_columns', 'exclude_regex_columns', 'rename_regex_columns',
    'rank_rows_within_group', 'encode_group_keep_rows', 'encode_group_unique_descending',
    'encode_compound_group', 'binomial_tail_and_ratio', 'dosage_to_alleles',
    'convert_one_character_column', 'convert_three_character_columns',
    'aggregate_columns_mean', 'aggregate_columns_sum', 'propagate_group_missing',
    'layout_even_positions', 'import_plain_tsv', 'import_gzip_tsv',
    'import_zip_member', 'import_gzip_row_window',
]


def build_case(family, specimen, identifier, snapshot):
    rng = random.Random(261115000 + specimen * 97 + FAMILIES.index(family) * 10007)
    p = identifier.lower()
    n, k = 3 + specimen % 7, 2 + specimen % 5
    cols = [f'c{i+1}' for i in range(k)]
    rows = [[f'gene{i+1:02}', *[rng.randint(-30, 70) + (i+1) * .13 + j * .07 for j in range(k)]] for i in range(n)]
    inp, out, metrics = p+'i', p+'o', p+'m'
    body = data_step(inp, [('gene','char'), *[(c,'num') for c in cols]], rows)
    expected = {}
    used = []
    def macro(name):
        used.append(name)
        return '%' + snapshot.add(name)

    if family.startswith('pivot_'):
        fill = -999 if family == 'pivot_sentinel_fill' else 0
        long_rows = []
        wanted = []
        for i,row in enumerate(rows):
            values = []
            for j,value in enumerate(row[1:]):
                absent = family != 'pivot_complete' and (i+j+specimen) % 4 == 0
                if not absent:
                    long_rows.append([row[0],cols[j],value])
                values.append(fill if absent else value)
            wanted.append([row[0], *values])
        body = data_step(inp, [('gene','char'),('tissue','char'),('expression','num')], long_rows)
        body += macro('longdsd2matlabmatrix')+f'(dsd={inp},var_row=gene,var_col=tissue,data_var=expression,value2asign4missing={fill},dsdout={out},outdir4matrix=);\n'
        expected = expected_rows(wanted, cols)
        body += flatten(out,cols,metric_table=metrics)
    elif family.startswith('zscore_'):
        rowwise = family == 'zscore_rows'
        body += macro('Zscore4matrix')+f'(dsdin={inp},rowwide={int(rowwise)},ByVar4rowwide=gene,dsdout={out});\n'
        wanted=[]
        for i,row in enumerate(rows):
            values=[]
            for j,value in enumerate(row[1:]):
                population=row[1:] if rowwise else [r[j+1] for r in rows]
                values.append((value-statistics.mean(population))/statistics.stdev(population))
            wanted.append([row[0],*values])
        expected=expected_rows(wanted,cols)
        body+=flatten(out,cols,metric_table=metrics)
    elif family=='column_type_inventory':
        numeric=specimen%2
        extras=[f'label{i+1}' for i in range(1+specimen%5)]
        body=data_step(inp,[('gene','char'),*[(c,'num') for c in cols],*[(c,'char') for c in extras]],
                       [[*r,*[f'text{i}' for i in range(len(extras))]] for r in rows])
        body+=macro('get_num_or_char_vars4dsd')+f'(indsd=work.{inp},outdsd={out},numeric={numeric});\n'
        body+=f'data {metrics}(keep=metric value);set {out};length metric $120;metric=cats("column:",upcase(name));value=(type="num");run;\n'
        expected={f'column:{c.upper()}':1 for c in cols} if numeric else {f'column:{c.upper()}':0 for c in ['gene',*extras]}
    elif family in ('keep_regex_columns','exclude_regex_columns'):
        selected=[c for j,c in enumerate(cols) if j%2==specimen%2]
        if not selected:selected=cols[:1]
        # DICTIONARY.COLUMNS names are fixed-width character values; the
        # original macro does not STRIP() before matching an anchored pattern.
        regex='^('+ '|'.join(selected)+')[[:space:]]*$'
        if family=='keep_regex_columns':
            regex='^(gene|'+'|'.join(selected)+')[[:space:]]*$'
            body+=macro('KeepColMatchingRgx')+f'(indsd=work.{inp},Rgx={regex},outdsd={out},insensitive=1);\n'
            keep=selected
        else:
            body+=macro('KeepColNotMatchingRgx')+f'(indsd=work.{inp},Rgx={regex},outdsd={out});\n'
            keep=[c for c in cols if c not in selected]
            if not keep:
                # k>=2 and alternating selection always leaves one column.
                raise ValueError('No retained numeric column')
        expected=expected_rows([[r[0],*[r[cols.index(c)+1] for c in keep]] for r in rows],keep)
        body+=flatten(out,keep,metric_table=metrics)
        body+=f'proc contents data={out} out={p}s(keep=name type) noprint;run;data {p}s(keep=metric value);set {p}s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base={metrics} data={p}s;run;\n'
        expected.update({'schema:GENE':2,**{'schema:'+c.upper():1 for c in keep}})
    elif family=='rename_regex_columns':
        body=data_step(inp,[('gene','char'),*[(f'raw_{c}','num') for c in cols]],rows)
        body+=macro('Rename_Del_Rgx4All_Vars')+f'(indsd=work.{inp},Rgx=raw_);\n'
        expected=expected_rows(rows,cols);body+=flatten(inp,cols,metric_table=metrics)
        body+=f'proc contents data={inp} out={p}s(keep=name type) noprint;run;data {p}s(keep=metric value);set {p}s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base={metrics} data={p}s;run;\n'
        expected.update({'schema:GENE':2,**{'schema:'+c.upper():1 for c in cols}})
    elif family in ('rank_rows_within_group','encode_group_keep_rows','encode_group_unique_descending','encode_compound_group','propagate_group_missing'):
        grouped=[]
        for i in range(n+4):
            grouped.append([f'id{i+1:02}',f'g{1+i%3}',f't{1+(i//3)%2}',rng.randint(1,1000)+i*.01])
        rng.shuffle(grouped)
        body=data_step(inp,[('gene','char'),('grp','char'),('trait','char'),('amount','num')],grouped)
        if family=='rank_rows_within_group':
            descending=specimen%2
            body+=macro('number_rows_by_grp')+f'(dsdin={inp},grp_var=grp,num_var4sort=amount,descending_or_not={descending},dsdout={out});\n'
            for group in sorted({r[1] for r in grouped}):
                members=sorted((r for r in grouped if r[1]==group),key=lambda r:r[3],reverse=bool(descending))
                expected.update({r[0]+':ord':rank+1 for rank,r in enumerate(members)})
            body+=flatten(out,['ord'],metric_table=metrics)
        elif family=='propagate_group_missing':
            bad={r[1] for i,r in enumerate(grouped) if i==specimen%len(grouped)}
            for group in bad:
                next(r for r in grouped if r[1]==group)[3]=None
            body=data_step(inp,[('gene','char'),('grp','char'),('trait','char'),('amount','num')],grouped)
            body+=macro('AddMissingTag4Grps')+f'(dsdin={inp},grp_vars=grp,value_var=amount,varname4missingtag=mtag,dsdout={out});\n'
            expected={r[0]+':mtag':int(r[1] in bad) for r in grouped}
            body+=flatten(out,['mtag'],metric_table=metrics)
        elif family=='encode_compound_group':
            body+=macro('char_grp_to_num_grp4dups')+f'(dsdin={inp},grp_vars4sort=grp trait,descending_or_not=0,dsdout={out},num_grp_output_name=code);\n'
            keys=sorted({r[1]+':'+r[2] for r in grouped})
            expected={r[0]+':code':keys.index(r[1]+':'+r[2])+1 for r in grouped}
            body+=flatten(out,['code'],metric_table=metrics)
        else:
            unique=family=='encode_group_unique_descending'
            descending=int(unique)
            body+=macro('char_grp_to_num_grp')+f'(dsdin={inp},grp_vars4sort=grp,descending_or_not={descending},dsdout={out},num_grp_output_name=code,keep_uniq_rows_by_grp={int(unique)});\n'
            groups=sorted({r[1] for r in grouped},reverse=bool(descending))
            expected={(r[1] if unique else r[0])+':code':groups.index(r[1])+1 for r in grouped}
            body+=flatten(out,['code'],key='grp' if unique else 'gene',metric_table=metrics)
    elif family=='binomial_tail_and_ratio':
        counts=[[f'allele{i+1:02}',rng.randint(0,40),rng.randint(1,40)] for i in range(n)]
        cutoff=2+specimen%9
        body=data_step(inp,[('gene','char'),('ref','num'),('alt','num')],counts)
        body+=macro('calculate_binomial_P')+f'(dsdin={inp},dsdout={out},Allele1_var=ref,Allele2_var=alt,TotReadCutoff={cutoff});\n'
        variables=['tot_reads','binomial_P','logP','Ref_Frq','A1A2log2Ratio']
        wanted=[]
        for gene,a,b in counts:
            if a+b<cutoff:continue
            probability=sum(math.comb(a+b,j) for j in range(min(a,b)+1))/2**(a+b)
            wanted.append([gene,a+b,probability,-math.log10(probability),100*a/(a+b),max(-10,min(10,math.log2((a+.0001)/(b+.0001))))])
        expected=expected_rows(wanted,variables);body+=flatten(out,variables,metric_table=metrics)
    elif family=='dosage_to_alleles':
        genotypes=[[f's{i+1:02}',*[rng.choice([0,0,1,2,None,99]) for _ in range(k)]] for i in range(n)]
        body=data_step(inp,[('id','char'),*[(c,'num') for c in cols]],genotypes)
        body+=macro('additive_geno2alleles')+f'(indsd={inp},snp_varnames={" ".join(cols)},sample_id=id,outdsd={out});\n'
        mvars=[f'm{i+1}' for i in range(2*k)]
        body+=f'data {metrics}(keep=metric value);set {out};length metric $120;array a[*] $ {" ".join(mvars)};do j=1 to dim(a);metric=catx(":",id,vname(a[j]));value=input(a[j],??best32.);output;end;run;\n'
        for gene,*values in genotypes:
            if all(v in (None,99) for v in values):continue
            for j,v in enumerate(values):
                alleles={0:(0,0),1:(0,1),2:(1,1)}.get(v,(None,None))
                expected[gene+':m'+str(2*j+1)]=alleles[0];expected[gene+':m'+str(2*j+2)]=alleles[1]
    elif family.startswith('convert_'):
        selected=cols[:1] if family=='convert_one_character_column' else cols[:min(3,k)]
        converted=[[r[0],*[str(v) for v in r[1:]]] for r in rows]
        body=data_step(inp,[('gene','char'),*[(c,'char') for c in cols]],converted)
        body+=macro('char2num_dsd')+f'(dsdin={inp},vars={" ".join(selected)},dsdout={out});\n'
        body+=flatten(out,selected,metric_table=metrics)
        expected=expected_rows([[r[0],*[r[cols.index(c)+1] for c in selected]] for r in rows],selected)
    elif family.startswith('aggregate_columns_'):
        grouped=[[f'g{i%3+1}',*r[1:]] for i,r in enumerate(rows)]
        body=data_step(inp,[('grp','char'),*[(c,'num') for c in cols]],grouped)
        function='mean' if family.endswith('mean') else 'sum'
        body+=macro('ApplyFunc_rowwide')+f'(dsdin={inp},row_keys=grp,KeyVar4dsdout=keygrp,Regex4col_vars2apply=^c,SQL_Fun4apply={function},dsdout={out});\n'
        wanted=[]
        for group in sorted({r[0] for r in grouped}):
            values=[r[1:] for r in grouped if r[0]==group]
            wanted.append([group,*[(statistics.mean if function=='mean' else sum)(r[j] for r in values) for j in range(k)]])
        expected=expected_rows(wanted,cols);body+=flatten(out,cols,key='keygrp',metric_table=metrics)
    elif family=='layout_even_positions':
        positions=sorted(rng.sample(range(5,200+specimen*3),n))
        bound=1000+specimen*10
        body=data_step(inp,[('gene','char'),('pos','num')],[[f'v{i+1:02}',x] for i,x in enumerate(positions)])
        body+=macro('adjust_close_positions')+f'(indsd={inp},outdsd={out},pos_var=pos,new_pos_var=display_pos,make_even_pos=1,dist_pct_to_cluster_pos=1,fixed_min_pos=0,fixed_max_pos={bound});\n'
        expected={f'v{i+1:02}:display_pos':(i+1)*(bound+1)/(n+1) for i in range(n)}
        body+=flatten(out,['display_pos'],metric_table=metrics)
    elif family.startswith('import_'):
        input_rows=[[f'cell{i+1:02}',rng.randint(-500,500)/10] for i in range(n+3)]
        content='gene\tmeasure\n'+''.join(f'{g}\t{v}\n' for g,v in input_rows)
        suffix='.tsv' if family=='import_plain_tsv' else '.zip' if family=='import_zip_member' else '.tsv.gz'
        file=DEST/'inputs'/(PREFIX+identifier.lower()+suffix);file.parent.mkdir(exist_ok=True)
        if suffix=='.zip':
            with zipfile.ZipFile(file,'w',compression=zipfile.ZIP_DEFLATED) as archive:
                member=zipfile.ZipInfo('nested/data.tsv' if specimen%2==0 else 'data.tsv',date_time=(2026,1,1,0,0,0));member.compress_type=zipfile.ZIP_DEFLATED
                archive.writestr(member,content)
        elif suffix.endswith('.gz'):
            file.write_bytes(gzip.compress(content.encode(),mtime=0))
        else:file.write_text(content,encoding='utf-8',newline='\n')
        first,maximum=2,len(input_rows)+1
        if family=='import_gzip_row_window':first=3+specimen%2;maximum=min(first+2+specimen%3,len(input_rows)+1)
        body=macro('ImportFileHeadersFromZIP')+f'(zip={file.as_posix()},filename_rgx=tsv[[:space:]]*$,obs=max,sasdsdout={out},deleteZIP=0,use_zcat=0,infile_command=%str(firstobs={first} obs={maximum} delimiter="09"x dsd truncover;length gene $80;input gene $ measure;));\n'
        body+=flatten(out,['measure'],metric_table=metrics)
        expected={g+':measure':v for g,v in input_rows[first-2:maximum-1]}
    else:
        raise ValueError(family)
    body=body.replace(f'data {metrics}(',f'data {metrics}(')
    return body,expected,used,dict(specimen=specimen,rows=n,columns=k,seed=261115000+specimen*97+FAMILIES.index(family)*10007)


def main():
    DEST.mkdir(parents=True,exist_ok=True)
    snapshots=Snapshot(DEST)
    cases=[]
    for family_index,family in enumerate(FAMILIES):
        for specimen in range(1,21):
            identifier='V'+str(6001+20*family_index+specimen-1)
            body,expected,used,inputs=build_case(family,specimen,identifier,snapshots)
            code=finish_program(identifier,body)
            (DEST/(identifier+'.sas')).write_text(code,encoding='utf-8',newline='\n')
            cases.append(dict(id=identifier,file=identifier+'.sas',family=family,inputs=inputs,
                              expected=expected,tolerance=1e-8,source_macros=used,
                              sha256=sha(code.encode()),behavior_sha256=sha(normalize_behavior(code).encode())))
    manifest=dict(schema=1,count=len(cases),collection='actual-library-macro-workflows',cases=cases,
                  source_root=str(LIBRARY),generated_repository_root=ROOT.as_posix(),macro_snapshots=list(snapshots.records.values()),
                  adaptation='Macro definitions are extracted and namespaced n26_; three explicitly recorded corrections repair ZIP root members and regex emptiness in test copies only. Original files unchanged. Synthetic inputs, independent cell-level numerical oracles.')
    (DEST/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8',newline='\n')
    assert len(cases)==500 and len({c['behavior_sha256'] for c in cases})==500
    print(json.dumps(dict(cases=len(cases),families=len(FAMILIES),macros=len(snapshots.records))))


if __name__=='__main__':main()
