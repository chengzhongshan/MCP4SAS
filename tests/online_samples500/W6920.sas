/* New workflow W6920; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6920i;
length gene $80;
gene='s01';effect=-0.7054235366375925;variance=0.22449365580745995;output;
gene='s02';effect=0.022954455999047108;variance=0.037706957539586174;output;
gene='s03';effect=-0.3193488204706727;variance=0.07149696383759052;output;
gene='s04';effect=0.5440901259350466;variance=0.05029819952836535;output;
gene='s05';effect=0.17840519340594718;variance=0.15334422558743033;output;
gene='s06';effect=-0.4324241523851702;variance=0.06906788903445077;output;
gene='s07';effect=-0.3585698059245208;variance=0.10237656737762414;output;
gene='s08';effect=0.4016277593022315;variance=0.05758717767522627;output;
gene='s09';effect=0.7096275364586562;variance=0.2712277401582969;output;
run;
proc sql;create table w6920o as select a.gene,sum(b.effect/b.variance)/sum(1/b.variance) as beta,1/sum(1/b.variance) as variance from w6920i as a,w6920i as b where a.gene ne b.gene group by a.gene;quit;
data w6920m(keep=metric value);set w6920o;length metric $120;array measured[*] beta variance;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6920m;set w6920m;format value best32.;run;
proc export data=w6920m outfile="%sysfunc(pathname(work))/W6920.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6920;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6920:;quit;
