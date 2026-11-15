/* New workflow W6786; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6786i;
length gene $80;
gene='p01';raw_p=0.8;output;
gene='p02';raw_p=0.945821120484084;output;
gene='p03';raw_p=0.5951706832374638;output;
gene='p04';raw_p=0.2;output;
gene='p05';raw_p=0.3197369695253569;output;
gene='p06';raw_p=0.7909579937672911;output;
gene='p07';raw_p=1;output;
gene='p08';raw_p=0.20276369971054142;output;
gene='p09';raw_p=0.23517721370830502;output;
gene='p10';raw_p=1;output;
gene='p11';raw_p=0.3461537856213396;output;
gene='p12';raw_p=0.1562599149708649;output;
run;
proc multtest inpvalues=w6786i stepsid out=w6786o noprint;run;
data w6786m(keep=metric value);set w6786o;length metric $120;array measured[*] stpsid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6786m;set w6786m;format value best32.;run;
proc export data=w6786m outfile="%sysfunc(pathname(work))/W6786.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6786;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6786:;quit;
