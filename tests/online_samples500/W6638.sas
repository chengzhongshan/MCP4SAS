/* New workflow W6638; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6638i;
length gene $80;
gene='s01';n=43;r=-0.2918894116665479;output;
gene='s02';n=80;r=0.2711143783465716;output;
gene='s03';n=82;r=-0.6091088378117585;output;
gene='s04';n=114;r=-0.33116721572643165;output;
gene='s05';n=74;r=0.691513328246232;output;
gene='s06';n=95;r=-0.591947647161019;output;
gene='s07';n=85;r=0.19998092508312693;output;
run;
data w6638o;set w6638i;z=.5*log((1+r)/(1-r));weight=n-3;variance=1/weight;lower=tanh(z-1.9599639845400536*sqrt(variance));upper=tanh(z+1.9599639845400536*sqrt(variance));run;
proc sql;create table w6638pool as select "pooled" as gene,sum(weight*z)/sum(weight) as z,1/sum(weight) as variance from w6638o;quit;data w6638pool;set w6638pool;r=tanh(z);run;
data w6638m(keep=metric value);set w6638pool;length metric $120;array measured[*] z variance r;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6638m;set w6638m;format value best32.;run;
proc export data=w6638m outfile="%sysfunc(pathname(work))/W6638.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6638;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6638:;quit;
