/* New workflow W6661; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6661i;
length gene $80;
gene='s01';effect=-0.3451508245536703;variance=0.02819745709302403;output;
gene='s02';effect=0.3529156526714523;variance=0.2972147758559037;output;
gene='s03';effect=-0.954120702847145;variance=0.054583025685465636;output;
gene='s04';effect=-0.5072671988004349;variance=0.025030186779778422;output;
run;
proc sql;create table w6661o as select "meta" as gene,sum(1/variance) as sw,sum(effect/variance)/calculated sw as beta,sum(effect*effect/variance)-sum(effect/variance)**2/calculated sw as q,count(*)-1 as df from w6661i;quit;data w6661o;set w6661o;i2=max(0,(q-df)/q);run;
data w6661m(keep=metric value);set w6661o;length metric $120;array measured[*] sw beta q df i2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6661m;set w6661m;format value best32.;run;
proc export data=w6661m outfile="%sysfunc(pathname(work))/W6661.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6661;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6661:;quit;
