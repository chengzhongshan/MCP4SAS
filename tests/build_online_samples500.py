"""500 new sample-derived numerical workflows; no original sample is edited."""
import csv
import io
import json
import math
from pathlib import Path
import random
import re
import statistics
import sys

from build_library_workflows500 import (ROOT, Snapshot, PREFIX, definitions, data_step,
    flatten, expected_rows, finish_program, sha, normalize_behavior)

BOOKS=Path('H:/F_Queens/360yunpan/SASCodesLibrary/SAS PDF/sas online samples')
META='Integrading Results through Meta analytic review using sas software.txt'
MULT='Multiple Comparisons and Multiple Tests Using SAS.txt'
EXTERNAL='Reading External Data Files Using SAS Examples Handbook.txt'
GRAPH='Quick Results with SAS_GRAPH Software.txt'
DEST=ROOT/'tests/online_samples500'
FAMILIES=['meta_odds_four_scales','meta_zero_cell_correction','meta_fixed_odds',
 'meta_fixed_odds_confidence','meta_weighted_effect_groups','meta_effect_size_scales',
 'meta_fisher_correlation_pool','meta_fisher_correlation_intervals','meta_weighted_heterogeneity',
 'meta_mantel_haenszel_point','adjust_data_bonferroni_sidak','adjust_proc_bonferroni',
 'adjust_proc_sidak','adjust_proc_holm','adjust_proc_step_sidak','adjust_proc_hochberg',
 'adjust_proc_bh_fdr','adjust_proc_by_fdr','adjust_fixed_sequence','combine_fisher_pvalues',
 'meta_leave_one_out','external_quoted_csv','external_short_records',
 'summary_grouped_plot_values','graphics_scatter_and_values']


class BookSnapshot(Snapshot):
    def definitions(self,text):
        # This is a plain-text book containing prose apostrophes outside SAS
        # programs. Parse its explicitly delimited top-level listings rather
        # than treating all surrounding prose as a single SAS program.
        return [(m[0],m.start()) for m in re.finditer(r'^%macro\s+\w+\b.*?^%mend\b[^;]*;',text,re.I|re.M|re.S)]

    def __init__(self):
        super().__init__(DEST,BOOKS)
        self.files={}
        file=BOOKS/META
        text=file.read_text(encoding='utf-8-sig',errors='replace')
        for chunk,_ in self.definitions(text):
            self.files[re.match(r'%macro\s+(\w+)',chunk,re.I)[1].casefold()]=file


def evidence(file,pattern):
    raw=(BOOKS/file).read_bytes();text=raw.decode('utf-8-sig',errors='replace')
    match=re.search(pattern,text,re.I)
    if not match:raise ValueError(f'Missing source anchor: {file}: {pattern}')
    return dict(file=file,sha256=sha(raw),line=1+text[:match.start()].count('\n'),
                anchor=text[match.start():text.find('\n',match.start())][:200],
                adaptation='Synthetic fixtures, paths/table names adapted; derived extensions labeled by family.')


def adjust(pvalues,method):
    m=len(pvalues);order=sorted(range(m),key=lambda i:pvalues[i]);sorted_p=[pvalues[i] for i in order]
    if method=='bon':out=[min(1,m*p) for p in sorted_p]
    elif method=='sid':out=[-math.expm1(m*math.log1p(-p)) if p<1 else 1 for p in sorted_p]
    elif method in ('holm','stepsid'):
        out=[];previous=0
        for j,p in enumerate(sorted_p):
            q=(m-j)*p if method=='holm' else (-math.expm1((m-j)*math.log1p(-p)) if p<1 else 1)
            previous=max(previous,min(1,q));out.append(previous)
    else:
        harmonic=sum(1/i for i in range(1,m+1));out=[0]*m;previous=1
        for j in reversed(range(m)):
            q=(m-j)*sorted_p[j] if method=='hoc' else m*sorted_p[j]/(j+1)*(harmonic if method=='dfdr' else 1)
            previous=min(previous,q,1);out[j]=previous
    result=[0]*m
    for index,value in zip(order,out):result[index]=value
    return result


def build_case(family,specimen,identifier,snapshot):
    rng=random.Random(261116000+specimen*193+FAMILIES.index(family)*19001)
    p=identifier.lower();inp,out,metrics=p+'i',p+'o',p+'m';body='';expected={};assets=[]
    n=3+specimen%7
    level=[.8,.9,.95,.99][specimen%4];z=statistics.NormalDist().inv_cdf((1+level)/2)
    source=evidence(META,r'%macro\s+compodds')
    def macro(name):return '%'+snapshot.add(name)
    if family in ('meta_odds_four_scales','meta_zero_cell_correction','meta_fixed_odds','meta_fixed_odds_confidence'):
        counts=[[rng.randint(8,45),rng.randint(20,90),rng.randint(7,40),rng.randint(25,95)] for _ in range(n)]
        if family=='meta_zero_cell_correction':counts=[[0,*counts[0][1:]]]
        elif family=='meta_odds_four_scales':counts=counts[:1]
        if family=='meta_fixed_odds_confidence':counts[0][0]=0
        body=data_step(inp,[(c,'num') for c in ['n11','n12','n21','n22']],counts)
        body+=macro('compodds')+f'({inp},{out});run;\n'
        variables=['estimate','lower','upper','variance']
        z95=statistics.NormalDist().inv_cdf(.975)
        if family in ('meta_odds_four_scales','meta_zero_cell_correction'):
            a,b,c,d=counts[0]
            for kind in range(1,5):
                corrected=kind>=3
                aa,bb,cc,dd=[v+.5 if corrected else v for v in [a,b,c,d]]
                if min(aa,bb,cc,dd)==0:
                    values=[None]*4
                else:
                    effect=math.log(aa*dd/(bb*cc));variance=sum(1/v for v in [aa,bb,cc,dd]);se=math.sqrt(variance)
                    values=[effect,effect-z95*se,effect+z95*se,variance]
                    if kind%2==0:values=[math.exp(v) for v in values[:3]]+[None]
                expected.update({f'type{kind}:{v}':x for v,x in zip(variables,values)})
            body+=flatten(out,variables,key="cats('type',type)",metric_table=metrics)
        else:
            corrected=family=='meta_fixed_odds_confidence';kind=3 if corrected else 1
            confidence=level if corrected else .95;critical=statistics.NormalDist().inv_cdf((1+confidence)/2)
            pooled=p+'pool';body+=macro('wavgodds')+f'({out},{pooled},{kind},{confidence});run;\n'
            weights=[];effects=[]
            for cells in counts:
                cells=[v+.5 if corrected else v for v in cells]
                weights.append(1/sum(1/v for v in cells));effects.append(math.log(cells[0]*cells[3]/(cells[1]*cells[2])))
            effect=sum(w*b for w,b in zip(weights,effects))/sum(weights);se=1/math.sqrt(sum(weights))
            variables=['estimate','lower','upper','level']
            values=[effect,effect-critical*se,effect+critical*se,confidence]
            for t in (kind,kind+1):
                converted=values if t==kind else [math.exp(v) for v in values[:3]]+[confidence]
                expected.update({f'type{t}:{v}':x for v,x in zip(variables,converted)})
            body+=flatten(pooled,variables,key="cats('type',type)",metric_table=metrics)
            source=evidence(META,r'%macro\s+wavgodds')
    elif family=='meta_weighted_effect_groups':
        rows=[[f'g{i%3+1}',rng.uniform(-.8,.9),rng.uniform(.02,.4)] for i in range(n+4)]
        body=data_step(inp,[('grp','char'),('eff','num'),('veff','num')],rows)
        body+='%let varlist=grp;\n'+macro('wavgeff')+f'({inp},{out},{level});run;\n'
        variables=['estimate','variance','lower','upper','level']
        for g in sorted({r[0] for r in rows}):
            members=[r for r in rows if r[0]==g];weight=sum(1/r[2] for r in members)
            estimate=sum(r[1]/r[2] for r in members)/weight;variance=1/weight
            expected.update({f'{g}:{v}':x for v,x in zip(variables,[estimate,variance,estimate-z*math.sqrt(variance),estimate+z*math.sqrt(variance),level])})
        body+=flatten(out,variables,key='grp',metric_table=metrics);source=evidence(META,r'%macro\s+wavgeff')
    elif family=='meta_effect_size_scales':
        ne,nc=20+specimen*2,25+specimen;me,mc=2+specimen/8,.5;se,sc=1+specimen/20,1.3+specimen/30
        body=data_step(inp,[(c,'num') for c in ['ne','nc','me','mc','se','sc']],[[ne,nc,me,mc,se,sc]])
        body+=macro('compeff')+f'({inp},{out});run;\n';source=evidence(META,r'%macro\s+compeff')
        total=ne+nc;df=total-2;delta=(me-mc)/sc
        d=(me-mc)/math.sqrt(((ne-1)*se**2+(nc-1)*sc**2)/total)
        g=(me-mc)/math.sqrt(((ne-1)*se**2+(nc-1)*sc**2)/df)
        gu=g*math.exp(math.lgamma(df/2)-math.lgamma((df-1)/2)-math.log(math.sqrt(df/2)))
        r=math.sqrt(ne*nc*d*d/(ne*nc*d*d+total*total));critical=statistics.NormalDist().inv_cdf(.975)
        for t,(estimate,var) in enumerate([(delta,total/(ne*nc)+delta**2/(2*nc-2)),(d,total/(ne*nc)+.5*d*d/df),(g,total/(ne*nc)+.5*g*g/df),(gu,total/(ne*nc)+.5*gu*gu/total)]):
            values=[estimate,estimate-critical*math.sqrt(var),estimate+critical*math.sqrt(var)]
            expected.update({f'type{t}:{v}':x for v,x in zip(['estimate','lower','upper'],values)})
        center=math.atanh(r);spread=critical/math.sqrt(total-3)
        expected.update({f'type4:{v}':x for v,x in zip(['estimate','lower','upper'],[r,math.tanh(center-spread),math.tanh(center+spread)])})
        body+=flatten(out,['estimate','lower','upper'],key="cats('type',type)",metric_table=metrics)
    elif family in ('meta_fisher_correlation_pool','meta_fisher_correlation_intervals'):
        rows=[[f's{i+1:02}',rng.randint(12,150),rng.uniform(-.7,.7)] for i in range(n)]
        body=data_step(inp,[('gene','char'),('n','num'),('r','num')],rows)
        body+=f'data {out};set {inp};z=.5*log((1+r)/(1-r));weight=n-3;variance=1/weight;lower=tanh(z-{z}*sqrt(variance));upper=tanh(z+{z}*sqrt(variance));run;\n'
        if family.endswith('pool'):
            body+=f'proc sql;create table {p}pool as select "pooled" as gene,sum(weight*z)/sum(weight) as z,1/sum(weight) as variance from {out};quit;data {p}pool;set {p}pool;r=tanh(z);run;\n'
            weights=[r[1]-3 for r in rows];zz=sum(w*math.atanh(r[2]) for w,r in zip(weights,rows))/sum(weights)
            expected={'pooled:z':zz,'pooled:variance':1/sum(weights),'pooled:r':math.tanh(zz)}
            body+=flatten(p+'pool',['z','variance','r'],metric_table=metrics)
        else:
            expected=expected_rows([[g,math.atanh(r),1/(size-3),math.tanh(math.atanh(r)-z/math.sqrt(size-3)),math.tanh(math.atanh(r)+z/math.sqrt(size-3))] for g,size,r in rows],['z','variance','lower','upper'])
            body+=flatten(out,['z','variance','lower','upper'],metric_table=metrics)
        source=evidence(META,r'z\s*=\s*0\.5\*log')
    elif family in ('meta_weighted_heterogeneity','meta_leave_one_out'):
        rows=[[f's{i+1:02}',rng.uniform(-1,1),rng.uniform(.02,.3)] for i in range(n)]
        body=data_step(inp,[('gene','char'),('effect','num'),('variance','num')],rows)
        weights=[1/r[2] for r in rows];total=sum(weights);beta=sum(w*r[1] for w,r in zip(weights,rows))/total
        if family=='meta_weighted_heterogeneity':
            q=sum(w*(r[1]-beta)**2 for w,r in zip(weights,rows))
            body+=f'proc sql;create table {out} as select "meta" as gene,sum(1/variance) as sw,sum(effect/variance)/calculated sw as beta,sum(effect*effect/variance)-sum(effect/variance)**2/calculated sw as q,count(*)-1 as df from {inp};quit;data {out};set {out};i2=max(0,(q-df)/q);run;\n'
            expected={'meta:sw':total,'meta:beta':beta,'meta:q':q,'meta:df':n-1,'meta:i2':max(0,(q-n+1)/q)}
            variables=['sw','beta','q','df','i2']
        else:
            body+=f'proc sql;create table {out} as select a.gene,sum(b.effect/b.variance)/sum(1/b.variance) as beta,1/sum(1/b.variance) as variance from {inp} as a,{inp} as b where a.gene ne b.gene group by a.gene;quit;\n'
            expected={}
            for i,r in enumerate(rows):
                weight=total-weights[i];estimate=(beta*total-weights[i]*r[1])/weight
                expected[r[0]+':beta']=estimate;expected[r[0]+':variance']=1/weight
            variables=['beta','variance']
        body+=flatten(out,variables,metric_table=metrics);source=evidence(META,r'%macro\s+wavgeff')
        source['derived_extension']=True
    elif family=='meta_mantel_haenszel_point':
        rows=[[rng.randint(8,40),rng.randint(20,70),rng.randint(5,30),rng.randint(30,80)] for _ in range(n)]
        body=data_step(inp,[(c,'num') for c in ['n11','n12','n21','n22']],rows)
        body+=macro('mhodds')+f'({inp},{out},{level});run;\n'
        odds=sum(a*d/(a+b+c+d) for a,b,c,d in rows)/sum(b*c/(a+b+c+d) for a,b,c,d in rows)
        expected={'type6:estimate':odds,'type5:estimate':math.log(odds)}
        body+=flatten(out,['estimate'],key="cats('type',type)",metric_table=metrics);source=evidence(META,r'%macro\s+mhodds')
        source['scope']='Point estimator only; legacy confidence-interval construction is not endorsed.'
    elif family.startswith('adjust_'):
        ps=[rng.choice([0,.00001,.001,.005,.01,.05,.2,.8,1]) if i%3==0 else rng.random() for i in range(n+3)]
        rows=[[f'p{i+1:02}',pval] for i,pval in enumerate(ps)]
        body=data_step(inp,[('gene','char'),('raw_p','num')],rows)
        source=evidence(MULT,r'Program 2\.4')
        if family=='adjust_data_bonferroni_sidak':
            body+=f'data {out};set {inp};bon_p=min(1,{len(ps)}*raw_p);sid_p=1-(1-raw_p)**{len(ps)};run;\n'
            variables=['bon_p','sid_p'];vectors=[adjust(ps,'bon'),adjust(ps,'sid')]
        elif family=='adjust_fixed_sequence':
            body+=f'data {out};set {inp};retain adjusted 0;adjusted=max(adjusted,raw_p);run;\n'
            values=[];value=0
            for pval in ps:value=max(value,pval);values.append(value)
            variables=['adjusted'];vectors=[values];source=evidence(MULT,r'Program 2\.12')
        else:
            method,column={'adjust_proc_bonferroni':('bon','bon_p'),'adjust_proc_sidak':('sid','sid_p'),
              'adjust_proc_holm':('holm','stpbon_p'),'adjust_proc_step_sidak':('stepsid','stpsid_p'),
              'adjust_proc_hochberg':('hoc','hoc_p'),'adjust_proc_bh_fdr':('fdr','fdr_p'),
              'adjust_proc_by_fdr':('dfdr','dfdr_p')}[family]
            option='dependentfdr' if method=='dfdr' else method
            body+=f'proc multtest inpvalues={inp} {option} out={out} noprint;run;\n'
            variables=[column];vectors=[adjust(ps,method)]
        expected={g+':'+var:values[i] for i,(g,_) in enumerate(rows) for var,values in zip(variables,vectors)}
        body+=flatten(out,variables,metric_table=metrics)
    elif family=='combine_fisher_pvalues':
        ps=[rng.uniform(.0001,.9) for _ in range(n)]
        body=data_step(inp,[('p','num')],[[pval] for pval in ps])
        body+=f'proc sql;create table {out} as select "combined" as gene,-2*sum(log(p)) as statistic,2*count(*) as df from {inp};quit;data {out};set {out};p=1-probchi(statistic,df);run;\n'
        statistic=-2*sum(map(math.log,ps));half=statistic/2
        expected={'combined:statistic':statistic,'combined:df':2*n,'combined:p':math.exp(-half)*sum(half**i/math.factorial(i) for i in range(n))}
        body+=flatten(out,['statistic','df','p'],metric_table=metrics);source=evidence(META,r'%macro\s+multrt');source['derived_extension']=True
    elif family.startswith('external_'):
        file=DEST/'inputs'/(PREFIX+identifier.lower()+'.csv');file.parent.mkdir(exist_ok=True)
        if family=='external_quoted_csv':
            rows=[[f'case,{i+1}',rng.randint(-100,100),rng.randint(0,300)/10] for i in range(n)]
            stream=io.StringIO();writer=csv.writer(stream,lineterminator='\n');writer.writerow(['gene','x','y']);writer.writerows(rows);file.write_text(stream.getvalue(),encoding='utf-8',newline='\n')
            body=f'data {out};length gene $80;infile "{file.as_posix()}" dsd dlm="," firstobs=2 truncover;input gene $ x y;run;\n'
            expected=expected_rows(rows,['x','y']);variables=['x','y']
        else:
            rows=[[f'case{i+1:02}',rng.randint(1,100),None if i%3==0 else rng.randint(-10,10)] for i in range(n)]
            file.write_text(''.join(f'{g},{x}'+('' if y is None else ','+str(y))+'\n' for g,x,y in rows),encoding='utf-8',newline='\n')
            body=f'data {out};length gene $80;infile "{file.as_posix()}" dsd dlm="," truncover;input gene $ x y;run;\n'
            expected=expected_rows(rows,['x','y']);variables=['x','y']
        body+=flatten(out,variables,metric_table=metrics);source=evidence(EXTERNAL,r'\binfile\b')
    elif family=='summary_grouped_plot_values':
        rows=[[f'g{i%3+1}',rng.randint(-20,100)/4] for i in range(n+5)]
        body=data_step(inp,[('grp','char'),('amount','num')],rows)
        body+=f'proc summary data={inp} nway;class grp;var amount;output out={out} n=n sum=total mean=average min=smallest max=largest;run;\n'
        variables=['n','total','average','smallest','largest']
        for g in sorted({r[0] for r in rows}):
            values=[r[1] for r in rows if r[0]==g]
            expected.update({g+':'+v:x for v,x in zip(variables,[len(values),sum(values),statistics.mean(values),min(values),max(values)])})
        body+=flatten(out,variables,key='grp',metric_table=metrics);source=evidence(GRAPH,r'\bproc\s+')
        source['derived_extension']=True
    elif family=='graphics_scatter_and_values':
        rows=[[f'v{i+1:02}',i/3,rng.uniform(-2,4)+i/5] for i in range(n+6)]
        body=data_step(inp,[('gene','char'),('x','num'),('y','num')],rows)
        width,height=500+specimen%4*40,350+specimen%3*30
        body+=f'ods listing gpath="%sysfunc(pathname(work))";ods graphics /reset=index imagename="{identifier}" outputfmt=svg width={width}px height={height}px;title "{identifier}: synthetic SAS regression fixture";proc sgplot data={inp};scatter x=x y=y/markerattrs=(size={4+specimen%5});run;title;ods listing close;\n'
        body+=flatten(inp,['x','y'],metric_table=metrics);expected=expected_rows(rows,['x','y']);assets=[identifier+'.svg']
        source=evidence(GRAPH,r'\bproc\s+gplot');source['derived_extension']=True;source['scope']='Original graphics example adapted to current ODS/SGPLOT, synthetic data; numerical values and rendering checked separately.'
    else:raise ValueError(family)
    return body,expected,source,assets,dict(specimen=specimen,seed=261116000+specimen*193+FAMILIES.index(family)*19001)


def main():
    DEST.mkdir(parents=True,exist_ok=True);snapshots=BookSnapshot();cases=[]
    for index,family in enumerate(FAMILIES):
        for specimen in range(1,21):
            identifier='W'+str(6501+20*index+specimen-1)
            body,expected,source,assets,inputs=build_case(family,specimen,identifier,snapshots)
            code=finish_program(identifier,body);(DEST/(identifier+'.sas')).write_text(code,encoding='utf-8',newline='\n')
            cases.append(dict(id=identifier,file=identifier+'.sas',family=family,inputs=inputs,expected=expected,tolerance=1e-8,
                              evidence=source,assets=assets,sha256=sha(code.encode()),behavior_sha256=sha(normalize_behavior(code).encode())))
    assert len(cases)==500 and len({c['behavior_sha256'] for c in cases})==500
    manifest=dict(schema=1,count=500,collection='online-samples-new-workflows',cases=cases,source_root=str(BOOKS),generated_repository_root=ROOT.as_posix(),
       macro_snapshots=list(snapshots.records.values()),attribution='Meta-analysis code: Morgan C. Wang and Brad J. Bushman. Multiple testing samples: Westfall, Tobias, Rom, Wolfinger, Hochberg. External data examples: Michele M. Burlew. Original local files unchanged.',
       references=['https://support.sas.com/documentation/cdl/en/statug/63033/HTML/default/statug_multtest_sect017.htm','https://support.sas.com/documentation/cdl/en/statug/63033/HTML/default/statug_multtest_sect014.htm'],
       scientific_scope='Synthetic test fixtures. Original book compatibility tests are not endorsement of every legacy definition or confidence interval; derived extensions are labeled.')
    (DEST/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(json.dumps(dict(cases=500,families=len(FAMILIES),macros=len(snapshots.records))))


if __name__=='__main__':main()
