/* New workflow W6626; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6626i;
length gene $80;
gene='s01';n=124;r=-0.4603130291093661;output;
gene='s02';n=109;r=-0.2938610301155968;output;
gene='s03';n=146;r=-0.5219920693281592;output;
gene='s04';n=137;r=-0.022928685771998136;output;
gene='s05';n=47;r=0.6942688377677722;output;
gene='s06';n=107;r=-0.3471778586751667;output;
gene='s07';n=118;r=-0.08253420498110386;output;
gene='s08';n=25;r=-0.27231228662349893;output;
gene='s09';n=40;r=0.3722022143755426;output;
run;
data w6626o;set w6626i;z=.5*log((1+r)/(1-r));weight=n-3;variance=1/weight;lower=tanh(z-1.9599639845400536*sqrt(variance));upper=tanh(z+1.9599639845400536*sqrt(variance));run;
proc sql;create table w6626pool as select "pooled" as gene,sum(weight*z)/sum(weight) as z,1/sum(weight) as variance from w6626o;quit;data w6626pool;set w6626pool;r=tanh(z);run;
data w6626m(keep=metric value);set w6626pool;length metric $120;array measured[*] z variance r;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6626m;set w6626m;format value best32.;run;
proc export data=w6626m outfile="%sysfunc(pathname(work))/W6626.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6626;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6626:;quit;
