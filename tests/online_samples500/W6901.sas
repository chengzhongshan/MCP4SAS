/* New workflow W6901; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6901i;
length gene $80;
gene='s01';effect=0.6703209893064577;variance=0.05035921143929844;output;
gene='s02';effect=0.27541507354581074;variance=0.1348033924470172;output;
gene='s03';effect=0.31089275004907924;variance=0.13127274991803375;output;
gene='s04';effect=0.8586721376753259;variance=0.2626316139384118;output;
run;
proc sql;create table w6901o as select a.gene,sum(b.effect/b.variance)/sum(1/b.variance) as beta,1/sum(1/b.variance) as variance from w6901i as a,w6901i as b where a.gene ne b.gene group by a.gene;quit;
data w6901m(keep=metric value);set w6901o;length metric $120;array measured[*] beta variance;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6901m;set w6901m;format value best32.;run;
proc export data=w6901m outfile="%sysfunc(pathname(work))/W6901.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6901;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6901:;quit;
