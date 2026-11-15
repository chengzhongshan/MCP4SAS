/* New workflow W6636; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6636i;
length gene $80;
gene='s01';n=86;r=0.24581607901248803;output;
gene='s02';n=35;r=-0.5786939915705495;output;
gene='s03';n=113;r=0.12248041919622277;output;
gene='s04';n=65;r=-0.49821970501498813;output;
gene='s05';n=104;r=0.636029252835405;output;
run;
data w6636o;set w6636i;z=.5*log((1+r)/(1-r));weight=n-3;variance=1/weight;lower=tanh(z-1.2815515655446008*sqrt(variance));upper=tanh(z+1.2815515655446008*sqrt(variance));run;
proc sql;create table w6636pool as select "pooled" as gene,sum(weight*z)/sum(weight) as z,1/sum(weight) as variance from w6636o;quit;data w6636pool;set w6636pool;r=tanh(z);run;
data w6636m(keep=metric value);set w6636pool;length metric $120;array measured[*] z variance r;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6636m;set w6636m;format value best32.;run;
proc export data=w6636m outfile="%sysfunc(pathname(work))/W6636.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6636;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6636:;quit;
