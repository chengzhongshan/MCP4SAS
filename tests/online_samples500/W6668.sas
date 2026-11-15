/* New workflow W6668; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6668i;
length gene $80;
gene='s01';effect=0.2107764727296657;variance=0.2790718462572917;output;
gene='s02';effect=-0.12347591221370191;variance=0.21557054792558836;output;
gene='s03';effect=-0.127277272065222;variance=0.2400988709297219;output;
gene='s04';effect=-0.08474899288812665;variance=0.1733929102401211;output;
run;
proc sql;create table w6668o as select "meta" as gene,sum(1/variance) as sw,sum(effect/variance)/calculated sw as beta,sum(effect*effect/variance)-sum(effect/variance)**2/calculated sw as q,count(*)-1 as df from w6668i;quit;data w6668o;set w6668o;i2=max(0,(q-df)/q);run;
data w6668m(keep=metric value);set w6668o;length metric $120;array measured[*] sw beta q df i2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6668m;set w6668m;format value best32.;run;
proc export data=w6668m outfile="%sysfunc(pathname(work))/W6668.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6668;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6668:;quit;
