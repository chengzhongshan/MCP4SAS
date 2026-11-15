/* New workflow W6781; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6781i;
length gene $80;
gene='p01';raw_p=0.01;output;
gene='p02';raw_p=0.12100918480207568;output;
gene='p03';raw_p=0.6610730308822389;output;
gene='p04';raw_p=0.8;output;
gene='p05';raw_p=0.6597848127061713;output;
gene='p06';raw_p=0.20741221152302114;output;
gene='p07';raw_p=1;output;
run;
proc multtest inpvalues=w6781i stepsid out=w6781o noprint;run;
data w6781m(keep=metric value);set w6781o;length metric $120;array measured[*] stpsid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6781m;set w6781m;format value best32.;run;
proc export data=w6781m outfile="%sysfunc(pathname(work))/W6781.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6781;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6781:;quit;
