/* New workflow W6622; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6622i;
length gene $80;
gene='s01';n=71;r=-0.31700439622659216;output;
gene='s02';n=114;r=0.654233092339928;output;
gene='s03';n=93;r=0.5156694117267344;output;
gene='s04';n=107;r=-0.22032288263444288;output;
gene='s05';n=119;r=-0.6754318972737742;output;
run;
data w6622o;set w6622i;z=.5*log((1+r)/(1-r));weight=n-3;variance=1/weight;lower=tanh(z-1.9599639845400536*sqrt(variance));upper=tanh(z+1.9599639845400536*sqrt(variance));run;
proc sql;create table w6622pool as select "pooled" as gene,sum(weight*z)/sum(weight) as z,1/sum(weight) as variance from w6622o;quit;data w6622pool;set w6622pool;r=tanh(z);run;
data w6622m(keep=metric value);set w6622pool;length metric $120;array measured[*] z variance r;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6622m;set w6622m;format value best32.;run;
proc export data=w6622m outfile="%sysfunc(pathname(work))/W6622.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6622;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6622:;quit;
