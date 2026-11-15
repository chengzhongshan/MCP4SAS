/* New workflow W6634; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6634i;
length gene $80;
gene='s01';n=21;r=0.20771172798515358;output;
gene='s02';n=71;r=-0.4118413323248186;output;
gene='s03';n=76;r=-0.637384390048403;output;
run;
data w6634o;set w6634i;z=.5*log((1+r)/(1-r));weight=n-3;variance=1/weight;lower=tanh(z-1.9599639845400536*sqrt(variance));upper=tanh(z+1.9599639845400536*sqrt(variance));run;
proc sql;create table w6634pool as select "pooled" as gene,sum(weight*z)/sum(weight) as z,1/sum(weight) as variance from w6634o;quit;data w6634pool;set w6634pool;r=tanh(z);run;
data w6634m(keep=metric value);set w6634pool;length metric $120;array measured[*] z variance r;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6634m;set w6634m;format value best32.;run;
proc export data=w6634m outfile="%sysfunc(pathname(work))/W6634.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6634;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6634:;quit;
