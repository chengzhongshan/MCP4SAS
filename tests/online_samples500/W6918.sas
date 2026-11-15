/* New workflow W6918; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6918i;
length gene $80;
gene='s01';effect=-0.2969544914845563;variance=0.18238923532305623;output;
gene='s02';effect=0.1396164418713437;variance=0.050962933721365705;output;
gene='s03';effect=-0.43833973891012445;variance=0.27079697917341744;output;
gene='s04';effect=-0.8778010527287101;variance=0.2797492569393183;output;
gene='s05';effect=-0.7975914113052223;variance=0.03648664278114836;output;
gene='s06';effect=-0.3049172748675486;variance=0.07005467317608333;output;
gene='s07';effect=-0.2366524368507008;variance=0.10617033817171041;output;
run;
proc sql;create table w6918o as select a.gene,sum(b.effect/b.variance)/sum(1/b.variance) as beta,1/sum(1/b.variance) as variance from w6918i as a,w6918i as b where a.gene ne b.gene group by a.gene;quit;
data w6918m(keep=metric value);set w6918o;length metric $120;array measured[*] beta variance;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6918m;set w6918m;format value best32.;run;
proc export data=w6918m outfile="%sysfunc(pathname(work))/W6918.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6918;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6918:;quit;
