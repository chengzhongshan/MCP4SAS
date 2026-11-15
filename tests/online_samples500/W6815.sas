/* New workflow W6815; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6815i;
length gene $80;
gene='p01';raw_p=0.005;output;
gene='p02';raw_p=0.39027344410278575;output;
gene='p03';raw_p=0.5883813963796931;output;
gene='p04';raw_p=1;output;
gene='p05';raw_p=0.03065728911121579;output;
gene='p06';raw_p=0.9865764551860653;output;
gene='p07';raw_p=0.001;output;
run;
proc multtest inpvalues=w6815i hoc out=w6815o noprint;run;
data w6815m(keep=metric value);set w6815o;length metric $120;array measured[*] hoc_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6815m;set w6815m;format value best32.;run;
proc export data=w6815m outfile="%sysfunc(pathname(work))/W6815.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6815;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6815:;quit;
