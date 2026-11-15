/* New workflow W6629; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6629i;
length gene $80;
gene='s01';n=40;r=-0.5708478268774961;output;
gene='s02';n=76;r=-0.5854241786684364;output;
gene='s03';n=124;r=-0.43038543360936515;output;
gene='s04';n=103;r=0.1635717216020668;output;
gene='s05';n=88;r=0.21890866223239702;output;
run;
data w6629o;set w6629i;z=.5*log((1+r)/(1-r));weight=n-3;variance=1/weight;lower=tanh(z-1.6448536269514715*sqrt(variance));upper=tanh(z+1.6448536269514715*sqrt(variance));run;
proc sql;create table w6629pool as select "pooled" as gene,sum(weight*z)/sum(weight) as z,1/sum(weight) as variance from w6629o;quit;data w6629pool;set w6629pool;r=tanh(z);run;
data w6629m(keep=metric value);set w6629pool;length metric $120;array measured[*] z variance r;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6629m;set w6629m;format value best32.;run;
proc export data=w6629m outfile="%sysfunc(pathname(work))/W6629.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6629;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6629:;quit;
