/* New workflow W6903; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6903i;
length gene $80;
gene='s01';effect=-0.6827115932197922;variance=0.267205173728994;output;
gene='s02';effect=-0.3837886666074046;variance=0.2590151102859932;output;
gene='s03';effect=-0.06233913883872999;variance=0.2723195239299777;output;
gene='s04';effect=0.38861284277868013;variance=0.13639212084013927;output;
gene='s05';effect=-0.5697490394424953;variance=0.1639100401400048;output;
gene='s06';effect=-0.7963658756487162;variance=0.046535559210587996;output;
run;
proc sql;create table w6903o as select a.gene,sum(b.effect/b.variance)/sum(1/b.variance) as beta,1/sum(1/b.variance) as variance from w6903i as a,w6903i as b where a.gene ne b.gene group by a.gene;quit;
data w6903m(keep=metric value);set w6903o;length metric $120;array measured[*] beta variance;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6903m;set w6903m;format value best32.;run;
proc export data=w6903m outfile="%sysfunc(pathname(work))/W6903.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6903;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6903:;quit;
