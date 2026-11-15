/* New workflow W6639; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6639i;
length gene $80;
gene='s01';n=102;r=-0.05160895761366635;output;
gene='s02';n=94;r=0.6936669177037842;output;
gene='s03';n=37;r=0.37426033208654186;output;
gene='s04';n=69;r=-0.010434316801098742;output;
gene='s05';n=42;r=0.33685238340492885;output;
gene='s06';n=49;r=0.6625441813695834;output;
gene='s07';n=24;r=0.42360502094097763;output;
gene='s08';n=74;r=0.08860803751285695;output;
run;
data w6639o;set w6639i;z=.5*log((1+r)/(1-r));weight=n-3;variance=1/weight;lower=tanh(z-2.5758293035489*sqrt(variance));upper=tanh(z+2.5758293035489*sqrt(variance));run;
proc sql;create table w6639pool as select "pooled" as gene,sum(weight*z)/sum(weight) as z,1/sum(weight) as variance from w6639o;quit;data w6639pool;set w6639pool;r=tanh(z);run;
data w6639m(keep=metric value);set w6639pool;length metric $120;array measured[*] z variance r;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6639m;set w6639m;format value best32.;run;
proc export data=w6639m outfile="%sysfunc(pathname(work))/W6639.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6639;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6639:;quit;
