/* New workflow W6635; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6635i;
length gene $80;
gene='s01';n=14;r=0.31852738730594443;output;
gene='s02';n=90;r=0.2926945117861812;output;
gene='s03';n=77;r=-0.008600499529674899;output;
gene='s04';n=141;r=0.41358562952496114;output;
run;
data w6635o;set w6635i;z=.5*log((1+r)/(1-r));weight=n-3;variance=1/weight;lower=tanh(z-2.5758293035489*sqrt(variance));upper=tanh(z+2.5758293035489*sqrt(variance));run;
proc sql;create table w6635pool as select "pooled" as gene,sum(weight*z)/sum(weight) as z,1/sum(weight) as variance from w6635o;quit;data w6635pool;set w6635pool;r=tanh(z);run;
data w6635m(keep=metric value);set w6635pool;length metric $120;array measured[*] z variance r;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6635m;set w6635m;format value best32.;run;
proc export data=w6635m outfile="%sysfunc(pathname(work))/W6635.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6635;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6635:;quit;
