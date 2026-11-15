/* New workflow W6911; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6911i;
length gene $80;
gene='s01';effect=-0.7111645788135565;variance=0.1797822186941864;output;
gene='s02';effect=0.41285410002683376;variance=0.20698861416208666;output;
gene='s03';effect=0.09293501126388382;variance=0.08576432487643847;output;
gene='s04';effect=0.6936217943223577;variance=0.18095256341443394;output;
gene='s05';effect=0.20146928875858894;variance=0.28567072004468536;output;
gene='s06';effect=-0.5538144847113202;variance=0.06643182440354396;output;
gene='s07';effect=-0.2895895131998174;variance=0.27426777025592053;output;
run;
proc sql;create table w6911o as select a.gene,sum(b.effect/b.variance)/sum(1/b.variance) as beta,1/sum(1/b.variance) as variance from w6911i as a,w6911i as b where a.gene ne b.gene group by a.gene;quit;
data w6911m(keep=metric value);set w6911o;length metric $120;array measured[*] beta variance;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6911m;set w6911m;format value best32.;run;
proc export data=w6911m outfile="%sysfunc(pathname(work))/W6911.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6911;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6911:;quit;
