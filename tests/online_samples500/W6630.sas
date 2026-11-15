/* New workflow W6630; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6630i;
length gene $80;
gene='s01';n=83;r=-0.35748986160834606;output;
gene='s02';n=60;r=-0.4422331676374477;output;
gene='s03';n=15;r=-0.6545997486060372;output;
gene='s04';n=79;r=-0.5740598218594597;output;
gene='s05';n=138;r=0.1410973275896401;output;
gene='s06';n=42;r=0.3460709956796091;output;
run;
data w6630o;set w6630i;z=.5*log((1+r)/(1-r));weight=n-3;variance=1/weight;lower=tanh(z-1.9599639845400536*sqrt(variance));upper=tanh(z+1.9599639845400536*sqrt(variance));run;
proc sql;create table w6630pool as select "pooled" as gene,sum(weight*z)/sum(weight) as z,1/sum(weight) as variance from w6630o;quit;data w6630pool;set w6630pool;r=tanh(z);run;
data w6630m(keep=metric value);set w6630pool;length metric $120;array measured[*] z variance r;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6630m;set w6630m;format value best32.;run;
proc export data=w6630m outfile="%sysfunc(pathname(work))/W6630.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6630;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6630:;quit;
