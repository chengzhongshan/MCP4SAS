/* New workflow W6915; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6915i;
length gene $80;
gene='s01';effect=-0.126829100060462;variance=0.03994990823065489;output;
gene='s02';effect=0.4252995179554413;variance=0.2814788818449647;output;
gene='s03';effect=-0.09177781666203999;variance=0.22613312549252193;output;
gene='s04';effect=-0.52731500442846;variance=0.13179580258060752;output;
run;
proc sql;create table w6915o as select a.gene,sum(b.effect/b.variance)/sum(1/b.variance) as beta,1/sum(1/b.variance) as variance from w6915i as a,w6915i as b where a.gene ne b.gene group by a.gene;quit;
data w6915m(keep=metric value);set w6915o;length metric $120;array measured[*] beta variance;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6915m;set w6915m;format value best32.;run;
proc export data=w6915m outfile="%sysfunc(pathname(work))/W6915.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6915;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6915:;quit;
