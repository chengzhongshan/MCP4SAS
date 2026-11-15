/* New workflow W6909; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6909i;
length gene $80;
gene='s01';effect=0.7552747402290052;variance=0.2894508300285484;output;
gene='s02';effect=-0.9436497358184095;variance=0.23721434815462875;output;
gene='s03';effect=-0.66720420766578;variance=0.09698932641879962;output;
gene='s04';effect=-0.29279336603194084;variance=0.24372872880402544;output;
gene='s05';effect=0.43417629964603477;variance=0.1393081838260845;output;
run;
proc sql;create table w6909o as select a.gene,sum(b.effect/b.variance)/sum(1/b.variance) as beta,1/sum(1/b.variance) as variance from w6909i as a,w6909i as b where a.gene ne b.gene group by a.gene;quit;
data w6909m(keep=metric value);set w6909o;length metric $120;array measured[*] beta variance;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6909m;set w6909m;format value best32.;run;
proc export data=w6909m outfile="%sysfunc(pathname(work))/W6909.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6909;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6909:;quit;
