/* New workflow W6914; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6914i;
length gene $80;
gene='s01';effect=-0.1841578334072782;variance=0.2201276245509382;output;
gene='s02';effect=-0.5085575785416383;variance=0.18551482057278557;output;
gene='s03';effect=-0.9691803105214503;variance=0.03572767402810649;output;
run;
proc sql;create table w6914o as select a.gene,sum(b.effect/b.variance)/sum(1/b.variance) as beta,1/sum(1/b.variance) as variance from w6914i as a,w6914i as b where a.gene ne b.gene group by a.gene;quit;
data w6914m(keep=metric value);set w6914o;length metric $120;array measured[*] beta variance;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6914m;set w6914m;format value best32.;run;
proc export data=w6914m outfile="%sysfunc(pathname(work))/W6914.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6914;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6914:;quit;
