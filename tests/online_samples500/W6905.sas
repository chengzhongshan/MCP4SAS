/* New workflow W6905; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6905i;
length gene $80;
gene='s01';effect=-0.063280318116399;variance=0.2254655975179299;output;
gene='s02';effect=0.46497204145497184;variance=0.2823673363183412;output;
gene='s03';effect=0.8281353623374221;variance=0.25945801145762915;output;
gene='s04';effect=-0.8383325293998034;variance=0.13134485708094987;output;
gene='s05';effect=0.6981869829061866;variance=0.19080940332031202;output;
gene='s06';effect=-0.5760737385839463;variance=0.2119268827130785;output;
gene='s07';effect=0.8629758251453279;variance=0.05548613854950604;output;
gene='s08';effect=0.5618797542280336;variance=0.12814960400912478;output;
run;
proc sql;create table w6905o as select a.gene,sum(b.effect/b.variance)/sum(1/b.variance) as beta,1/sum(1/b.variance) as variance from w6905i as a,w6905i as b where a.gene ne b.gene group by a.gene;quit;
data w6905m(keep=metric value);set w6905o;length metric $120;array measured[*] beta variance;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6905m;set w6905m;format value best32.;run;
proc export data=w6905m outfile="%sysfunc(pathname(work))/W6905.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6905;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6905:;quit;
