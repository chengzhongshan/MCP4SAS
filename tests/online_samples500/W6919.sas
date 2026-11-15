/* New workflow W6919; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6919i;
length gene $80;
gene='s01';effect=0.663698793654024;variance=0.07657544861035973;output;
gene='s02';effect=0.9951775004165364;variance=0.05750641080398422;output;
gene='s03';effect=0.3769232101216502;variance=0.23828768446651402;output;
gene='s04';effect=-0.40272671281173844;variance=0.19698645126168085;output;
gene='s05';effect=0.04666153926824257;variance=0.09662602021787933;output;
gene='s06';effect=0.6850853273265591;variance=0.15785010075815722;output;
gene='s07';effect=-0.423589665292897;variance=0.21482979351547218;output;
gene='s08';effect=0.335389898011468;variance=0.23091205667641843;output;
run;
proc sql;create table w6919o as select a.gene,sum(b.effect/b.variance)/sum(1/b.variance) as beta,1/sum(1/b.variance) as variance from w6919i as a,w6919i as b where a.gene ne b.gene group by a.gene;quit;
data w6919m(keep=metric value);set w6919o;length metric $120;array measured[*] beta variance;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6919m;set w6919m;format value best32.;run;
proc export data=w6919m outfile="%sysfunc(pathname(work))/W6919.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6919;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6919:;quit;
