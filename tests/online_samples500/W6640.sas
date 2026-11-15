/* New workflow W6640; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6640i;
length gene $80;
gene='s01';n=21;r=-0.5136700526578282;output;
gene='s02';n=82;r=-0.37217127409113276;output;
gene='s03';n=145;r=0.37556953111493496;output;
gene='s04';n=72;r=-0.28400195274558;output;
gene='s05';n=141;r=-0.43823565940738557;output;
gene='s06';n=75;r=0.1777489576005864;output;
gene='s07';n=69;r=0.042773196424126914;output;
gene='s08';n=63;r=0.2200878136819705;output;
gene='s09';n=136;r=-0.12007721181092645;output;
run;
data w6640o;set w6640i;z=.5*log((1+r)/(1-r));weight=n-3;variance=1/weight;lower=tanh(z-1.2815515655446008*sqrt(variance));upper=tanh(z+1.2815515655446008*sqrt(variance));run;
proc sql;create table w6640pool as select "pooled" as gene,sum(weight*z)/sum(weight) as z,1/sum(weight) as variance from w6640o;quit;data w6640pool;set w6640pool;r=tanh(z);run;
data w6640m(keep=metric value);set w6640pool;length metric $120;array measured[*] z variance r;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6640m;set w6640m;format value best32.;run;
proc export data=w6640m outfile="%sysfunc(pathname(work))/W6640.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6640;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6640:;quit;
