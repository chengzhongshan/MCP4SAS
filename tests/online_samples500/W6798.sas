/* New workflow W6798; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6798i;
length gene $80;
gene='p01';raw_p=1e-05;output;
gene='p02';raw_p=0.40639084373554624;output;
gene='p03';raw_p=0.6514521593686922;output;
gene='p04';raw_p=0.01;output;
gene='p05';raw_p=0.43537401519853147;output;
gene='p06';raw_p=0.15223672774152885;output;
gene='p07';raw_p=0.05;output;
gene='p08';raw_p=0.7750818018787166;output;
gene='p09';raw_p=0.905673163665641;output;
gene='p10';raw_p=1;output;
run;
proc multtest inpvalues=w6798i stepsid out=w6798o noprint;run;
data w6798m(keep=metric value);set w6798o;length metric $120;array measured[*] stpsid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6798m;set w6798m;format value best32.;run;
proc export data=w6798m outfile="%sysfunc(pathname(work))/W6798.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6798;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6798:;quit;
