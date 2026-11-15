/* New workflow W6902; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6902i;
length gene $80;
gene='s01';effect=0.7614690960406951;variance=0.05565140361289572;output;
gene='s02';effect=-0.35875894740903136;variance=0.15917348432413428;output;
gene='s03';effect=-0.6760981857353769;variance=0.26825783971898;output;
gene='s04';effect=0.023707199282902325;variance=0.29434875495678386;output;
gene='s05';effect=-0.3713689249098391;variance=0.14587920023355325;output;
run;
proc sql;create table w6902o as select a.gene,sum(b.effect/b.variance)/sum(1/b.variance) as beta,1/sum(1/b.variance) as variance from w6902i as a,w6902i as b where a.gene ne b.gene group by a.gene;quit;
data w6902m(keep=metric value);set w6902o;length metric $120;array measured[*] beta variance;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6902m;set w6902m;format value best32.;run;
proc export data=w6902m outfile="%sysfunc(pathname(work))/W6902.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6902;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6902:;quit;
