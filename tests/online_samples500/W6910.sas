/* New workflow W6910; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6910i;
length gene $80;
gene='s01';effect=-0.9277884085818948;variance=0.07203212380361995;output;
gene='s02';effect=-0.3934697939809797;variance=0.03904589387841676;output;
gene='s03';effect=-0.9257271304610615;variance=0.15781760813257148;output;
gene='s04';effect=0.4483599263035958;variance=0.09341178629843142;output;
gene='s05';effect=0.22593979419131416;variance=0.16972928176899915;output;
gene='s06';effect=0.5189839531694804;variance=0.03220420911189839;output;
run;
proc sql;create table w6910o as select a.gene,sum(b.effect/b.variance)/sum(1/b.variance) as beta,1/sum(1/b.variance) as variance from w6910i as a,w6910i as b where a.gene ne b.gene group by a.gene;quit;
data w6910m(keep=metric value);set w6910o;length metric $120;array measured[*] beta variance;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6910m;set w6910m;format value best32.;run;
proc export data=w6910m outfile="%sysfunc(pathname(work))/W6910.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6910;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6910:;quit;
