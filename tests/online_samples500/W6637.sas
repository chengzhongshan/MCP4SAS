/* New workflow W6637; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6637i;
length gene $80;
gene='s01';n=85;r=-0.28355176769742246;output;
gene='s02';n=43;r=0.22595675998167586;output;
gene='s03';n=116;r=0.3498382551995425;output;
gene='s04';n=103;r=0.26215048613038305;output;
gene='s05';n=78;r=0.6512161190556927;output;
gene='s06';n=73;r=0.32667253170170785;output;
run;
data w6637o;set w6637i;z=.5*log((1+r)/(1-r));weight=n-3;variance=1/weight;lower=tanh(z-1.6448536269514715*sqrt(variance));upper=tanh(z+1.6448536269514715*sqrt(variance));run;
proc sql;create table w6637pool as select "pooled" as gene,sum(weight*z)/sum(weight) as z,1/sum(weight) as variance from w6637o;quit;data w6637pool;set w6637pool;r=tanh(z);run;
data w6637m(keep=metric value);set w6637pool;length metric $120;array measured[*] z variance r;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6637m;set w6637m;format value best32.;run;
proc export data=w6637m outfile="%sysfunc(pathname(work))/W6637.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6637;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6637:;quit;
