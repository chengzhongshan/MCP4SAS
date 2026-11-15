/* New workflow W6623; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6623i;
length gene $80;
gene='s01';n=72;r=-0.37591525711432994;output;
gene='s02';n=51;r=-0.6632053365213753;output;
gene='s03';n=40;r=0.6260774149817698;output;
gene='s04';n=53;r=-0.6928862310648461;output;
gene='s05';n=38;r=-0.18762943277707544;output;
gene='s06';n=60;r=0.18909606267738066;output;
run;
data w6623o;set w6623i;z=.5*log((1+r)/(1-r));weight=n-3;variance=1/weight;lower=tanh(z-2.5758293035489*sqrt(variance));upper=tanh(z+2.5758293035489*sqrt(variance));run;
proc sql;create table w6623pool as select "pooled" as gene,sum(weight*z)/sum(weight) as z,1/sum(weight) as variance from w6623o;quit;data w6623pool;set w6623pool;r=tanh(z);run;
data w6623m(keep=metric value);set w6623pool;length metric $120;array measured[*] z variance r;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6623m;set w6623m;format value best32.;run;
proc export data=w6623m outfile="%sysfunc(pathname(work))/W6623.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6623;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6623:;quit;
