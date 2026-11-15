/* New workflow W6916; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6916i;
length gene $80;
gene='s01';effect=0.44149751692321515;variance=0.26091092941732286;output;
gene='s02';effect=-0.2742788096233957;variance=0.04619410774178616;output;
gene='s03';effect=0.1953790908506674;variance=0.09275851747206015;output;
gene='s04';effect=-0.6832726450293602;variance=0.24689224013461736;output;
gene='s05';effect=-0.7985953523233196;variance=0.14401937344373644;output;
run;
proc sql;create table w6916o as select a.gene,sum(b.effect/b.variance)/sum(1/b.variance) as beta,1/sum(1/b.variance) as variance from w6916i as a,w6916i as b where a.gene ne b.gene group by a.gene;quit;
data w6916m(keep=metric value);set w6916o;length metric $120;array measured[*] beta variance;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6916m;set w6916m;format value best32.;run;
proc export data=w6916m outfile="%sysfunc(pathname(work))/W6916.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6916;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6916:;quit;
