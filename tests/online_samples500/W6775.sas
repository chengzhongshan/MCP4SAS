/* New workflow W6775; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6775i;
length gene $80;
gene='p01';raw_p=0.8;output;
gene='p02';raw_p=0.6015894336608946;output;
gene='p03';raw_p=0.39566314319820284;output;
gene='p04';raw_p=1e-05;output;
gene='p05';raw_p=0.1695790142066801;output;
gene='p06';raw_p=0.4704650247696823;output;
gene='p07';raw_p=0.005;output;
run;
proc multtest inpvalues=w6775i holm out=w6775o noprint;run;
data w6775m(keep=metric value);set w6775o;length metric $120;array measured[*] stpbon_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6775m;set w6775m;format value best32.;run;
proc export data=w6775m outfile="%sysfunc(pathname(work))/W6775.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6775;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6775:;quit;
