/* New workflow W6675; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6675i;
length gene $80;
gene='s01';effect=-0.4132766499248328;variance=0.05156562797083486;output;
gene='s02';effect=0.20925797399738766;variance=0.03473940852006099;output;
gene='s03';effect=-0.2596935533427296;variance=0.22504307840953114;output;
gene='s04';effect=-0.7789598070758279;variance=0.053255525329496;output;
run;
proc sql;create table w6675o as select "meta" as gene,sum(1/variance) as sw,sum(effect/variance)/calculated sw as beta,sum(effect*effect/variance)-sum(effect/variance)**2/calculated sw as q,count(*)-1 as df from w6675i;quit;data w6675o;set w6675o;i2=max(0,(q-df)/q);run;
data w6675m(keep=metric value);set w6675o;length metric $120;array measured[*] sw beta q df i2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6675m;set w6675m;format value best32.;run;
proc export data=w6675m outfile="%sysfunc(pathname(work))/W6675.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6675;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6675:;quit;
