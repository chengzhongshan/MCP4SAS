/* New workflow W6808; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6808i;
length gene $80;
gene='p01';raw_p=1;output;
gene='p02';raw_p=0.9972252509111871;output;
gene='p03';raw_p=0.525287920288111;output;
gene='p04';raw_p=1e-05;output;
gene='p05';raw_p=0.0061646642464302515;output;
gene='p06';raw_p=0.2629637705467588;output;
gene='p07';raw_p=1;output;
run;
proc multtest inpvalues=w6808i hoc out=w6808o noprint;run;
data w6808m(keep=metric value);set w6808o;length metric $120;array measured[*] hoc_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6808m;set w6808m;format value best32.;run;
proc export data=w6808m outfile="%sysfunc(pathname(work))/W6808.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6808;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6808:;quit;
