/* New workflow W6627; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6627i;
length gene $80;
gene='s01';n=135;r=-0.183911776413752;output;
gene='s02';n=128;r=-0.23501246769769873;output;
gene='s03';n=90;r=-0.1536988427458138;output;
run;
data w6627o;set w6627i;z=.5*log((1+r)/(1-r));weight=n-3;variance=1/weight;lower=tanh(z-2.5758293035489*sqrt(variance));upper=tanh(z+2.5758293035489*sqrt(variance));run;
proc sql;create table w6627pool as select "pooled" as gene,sum(weight*z)/sum(weight) as z,1/sum(weight) as variance from w6627o;quit;data w6627pool;set w6627pool;r=tanh(z);run;
data w6627m(keep=metric value);set w6627pool;length metric $120;array measured[*] z variance r;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6627m;set w6627m;format value best32.;run;
proc export data=w6627m outfile="%sysfunc(pathname(work))/W6627.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6627;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6627:;quit;
