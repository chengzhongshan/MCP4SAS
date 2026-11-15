/* New workflow W6904; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6904i;
length gene $80;
gene='s01';effect=-0.9551723696155667;variance=0.2574766133865914;output;
gene='s02';effect=-0.6773232391075092;variance=0.10321554816406374;output;
gene='s03';effect=-0.41230006741432623;variance=0.16776339744022778;output;
gene='s04';effect=0.5495572148555803;variance=0.2774638413469155;output;
gene='s05';effect=-0.06439884381306493;variance=0.1536967923121134;output;
gene='s06';effect=-0.3534674654284846;variance=0.2853581839825626;output;
gene='s07';effect=0.14721520724323156;variance=0.11401739154551958;output;
run;
proc sql;create table w6904o as select a.gene,sum(b.effect/b.variance)/sum(1/b.variance) as beta,1/sum(1/b.variance) as variance from w6904i as a,w6904i as b where a.gene ne b.gene group by a.gene;quit;
data w6904m(keep=metric value);set w6904o;length metric $120;array measured[*] beta variance;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6904m;set w6904m;format value best32.;run;
proc export data=w6904m outfile="%sysfunc(pathname(work))/W6904.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6904;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6904:;quit;
