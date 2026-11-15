/* New workflow W6628; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6628i;
length gene $80;
gene='s01';n=137;r=-0.6422641804701189;output;
gene='s02';n=97;r=0.36807565892334404;output;
gene='s03';n=141;r=-0.4144843288393769;output;
gene='s04';n=70;r=0.13389636877323885;output;
run;
data w6628o;set w6628i;z=.5*log((1+r)/(1-r));weight=n-3;variance=1/weight;lower=tanh(z-1.2815515655446008*sqrt(variance));upper=tanh(z+1.2815515655446008*sqrt(variance));run;
proc sql;create table w6628pool as select "pooled" as gene,sum(weight*z)/sum(weight) as z,1/sum(weight) as variance from w6628o;quit;data w6628pool;set w6628pool;r=tanh(z);run;
data w6628m(keep=metric value);set w6628pool;length metric $120;array measured[*] z variance r;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6628m;set w6628m;format value best32.;run;
proc export data=w6628m outfile="%sysfunc(pathname(work))/W6628.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6628;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6628:;quit;
