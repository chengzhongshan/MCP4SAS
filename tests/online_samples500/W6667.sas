/* New workflow W6667; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6667i;
length gene $80;
gene='s01';effect=0.2653736454298852;variance=0.07034488610651488;output;
gene='s02';effect=0.7014164410565027;variance=0.19221027270755373;output;
gene='s03';effect=0.4613737385273142;variance=0.2861147367231125;output;
run;
proc sql;create table w6667o as select "meta" as gene,sum(1/variance) as sw,sum(effect/variance)/calculated sw as beta,sum(effect*effect/variance)-sum(effect/variance)**2/calculated sw as q,count(*)-1 as df from w6667i;quit;data w6667o;set w6667o;i2=max(0,(q-df)/q);run;
data w6667m(keep=metric value);set w6667o;length metric $120;array measured[*] sw beta q df i2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6667m;set w6667m;format value best32.;run;
proc export data=w6667m outfile="%sysfunc(pathname(work))/W6667.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6667;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6667:;quit;
