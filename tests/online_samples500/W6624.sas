/* New workflow W6624; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6624i;
length gene $80;
gene='s01';n=42;r=0.09150354800894545;output;
gene='s02';n=124;r=0.6071617924105768;output;
gene='s03';n=39;r=0.3811063326792392;output;
gene='s04';n=96;r=0.06360803077096555;output;
gene='s05';n=87;r=0.4152874724541993;output;
gene='s06';n=110;r=0.6759302239385507;output;
gene='s07';n=39;r=0.40353264782930376;output;
run;
data w6624o;set w6624i;z=.5*log((1+r)/(1-r));weight=n-3;variance=1/weight;lower=tanh(z-1.2815515655446008*sqrt(variance));upper=tanh(z+1.2815515655446008*sqrt(variance));run;
proc sql;create table w6624pool as select "pooled" as gene,sum(weight*z)/sum(weight) as z,1/sum(weight) as variance from w6624o;quit;data w6624pool;set w6624pool;r=tanh(z);run;
data w6624m(keep=metric value);set w6624pool;length metric $120;array measured[*] z variance r;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6624m;set w6624m;format value best32.;run;
proc export data=w6624m outfile="%sysfunc(pathname(work))/W6624.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6624;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6624:;quit;
