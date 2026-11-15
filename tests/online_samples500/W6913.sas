/* New workflow W6913; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6913i;
length gene $80;
gene='s01';effect=-0.6201887879331032;variance=0.21184223901528879;output;
gene='s02';effect=-0.1882643448762742;variance=0.17165915537698376;output;
gene='s03';effect=0.16793531864479694;variance=0.2975243854544332;output;
gene='s04';effect=-0.8090718351390556;variance=0.28013044952196287;output;
gene='s05';effect=0.3029942237537051;variance=0.062456875787395894;output;
gene='s06';effect=-0.9509902797774292;variance=0.0519783819972395;output;
gene='s07';effect=-0.6093294119420087;variance=0.25838988811228747;output;
gene='s08';effect=0.7541934535441601;variance=0.06832683846337631;output;
gene='s09';effect=-0.816759087261244;variance=0.2682385987445164;output;
run;
proc sql;create table w6913o as select a.gene,sum(b.effect/b.variance)/sum(1/b.variance) as beta,1/sum(1/b.variance) as variance from w6913i as a,w6913i as b where a.gene ne b.gene group by a.gene;quit;
data w6913m(keep=metric value);set w6913o;length metric $120;array measured[*] beta variance;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6913m;set w6913m;format value best32.;run;
proc export data=w6913m outfile="%sysfunc(pathname(work))/W6913.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6913;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6913:;quit;
