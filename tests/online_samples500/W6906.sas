/* New workflow W6906; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6906i;
length gene $80;
gene='s01';effect=-0.7552771905675391;variance=0.11678554447205113;output;
gene='s02';effect=0.2299911090977731;variance=0.18457542112234807;output;
gene='s03';effect=-0.9798516961365038;variance=0.2304169272029863;output;
gene='s04';effect=-0.057323924718442054;variance=0.060397527852511665;output;
gene='s05';effect=-0.7554394217906706;variance=0.12736299731883646;output;
gene='s06';effect=0.19806582077866808;variance=0.2068894251571359;output;
gene='s07';effect=0.4193528983413448;variance=0.22760095601404384;output;
gene='s08';effect=0.8515757698898911;variance=0.1505530291392054;output;
gene='s09';effect=-0.9656783893119543;variance=0.23224485786018276;output;
run;
proc sql;create table w6906o as select a.gene,sum(b.effect/b.variance)/sum(1/b.variance) as beta,1/sum(1/b.variance) as variance from w6906i as a,w6906i as b where a.gene ne b.gene group by a.gene;quit;
data w6906m(keep=metric value);set w6906o;length metric $120;array measured[*] beta variance;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6906m;set w6906m;format value best32.;run;
proc export data=w6906m outfile="%sysfunc(pathname(work))/W6906.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6906;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6906:;quit;
