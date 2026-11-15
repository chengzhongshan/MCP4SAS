/* New workflow W6631; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6631i;
length gene $80;
gene='s01';n=147;r=0.43432965522477707;output;
gene='s02';n=143;r=-0.016748328911521004;output;
gene='s03';n=95;r=0.4062477193792058;output;
gene='s04';n=22;r=-0.5489254169866833;output;
gene='s05';n=79;r=0.12956468514960762;output;
gene='s06';n=65;r=-0.1716225045612012;output;
gene='s07';n=60;r=-0.07512275673993862;output;
run;
data w6631o;set w6631i;z=.5*log((1+r)/(1-r));weight=n-3;variance=1/weight;lower=tanh(z-2.5758293035489*sqrt(variance));upper=tanh(z+2.5758293035489*sqrt(variance));run;
proc sql;create table w6631pool as select "pooled" as gene,sum(weight*z)/sum(weight) as z,1/sum(weight) as variance from w6631o;quit;data w6631pool;set w6631pool;r=tanh(z);run;
data w6631m(keep=metric value);set w6631pool;length metric $120;array measured[*] z variance r;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6631m;set w6631m;format value best32.;run;
proc export data=w6631m outfile="%sysfunc(pathname(work))/W6631.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6631;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6631:;quit;
