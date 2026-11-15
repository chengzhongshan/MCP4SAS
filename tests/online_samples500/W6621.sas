/* New workflow W6621; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6621i;
length gene $80;
gene='s01';n=21;r=0.27044579051823214;output;
gene='s02';n=53;r=-0.08671727809889684;output;
gene='s03';n=34;r=0.5661434819384221;output;
gene='s04';n=13;r=-0.5844820743708181;output;
run;
data w6621o;set w6621i;z=.5*log((1+r)/(1-r));weight=n-3;variance=1/weight;lower=tanh(z-1.6448536269514715*sqrt(variance));upper=tanh(z+1.6448536269514715*sqrt(variance));run;
proc sql;create table w6621pool as select "pooled" as gene,sum(weight*z)/sum(weight) as z,1/sum(weight) as variance from w6621o;quit;data w6621pool;set w6621pool;r=tanh(z);run;
data w6621m(keep=metric value);set w6621pool;length metric $120;array measured[*] z variance r;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6621m;set w6621m;format value best32.;run;
proc export data=w6621m outfile="%sysfunc(pathname(work))/W6621.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6621;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6621:;quit;
