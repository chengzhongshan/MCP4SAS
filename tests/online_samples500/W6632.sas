/* New workflow W6632; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6632i;
length gene $80;
gene='s01';n=88;r=-0.5601197150939771;output;
gene='s02';n=136;r=0.3774242248400115;output;
gene='s03';n=52;r=-0.5406750877589966;output;
gene='s04';n=42;r=0.24544239266513934;output;
gene='s05';n=115;r=-0.5477960907086104;output;
gene='s06';n=96;r=-0.45028499082895934;output;
gene='s07';n=116;r=0.3508980095836469;output;
gene='s08';n=23;r=-0.633541084498972;output;
run;
data w6632o;set w6632i;z=.5*log((1+r)/(1-r));weight=n-3;variance=1/weight;lower=tanh(z-1.2815515655446008*sqrt(variance));upper=tanh(z+1.2815515655446008*sqrt(variance));run;
proc sql;create table w6632pool as select "pooled" as gene,sum(weight*z)/sum(weight) as z,1/sum(weight) as variance from w6632o;quit;data w6632pool;set w6632pool;r=tanh(z);run;
data w6632m(keep=metric value);set w6632pool;length metric $120;array measured[*] z variance r;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6632m;set w6632m;format value best32.;run;
proc export data=w6632m outfile="%sysfunc(pathname(work))/W6632.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6632;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6632:;quit;
