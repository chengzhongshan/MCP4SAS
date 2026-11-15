/* New workflow W6809; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6809i;
length gene $80;
gene='p01';raw_p=1e-05;output;
gene='p02';raw_p=0.9898670891610699;output;
gene='p03';raw_p=0.04670399610242626;output;
gene='p04';raw_p=0;output;
gene='p05';raw_p=0.5885895217384461;output;
gene='p06';raw_p=0.6868212504014418;output;
gene='p07';raw_p=0.01;output;
gene='p08';raw_p=0.04389683760904228;output;
run;
proc multtest inpvalues=w6809i hoc out=w6809o noprint;run;
data w6809m(keep=metric value);set w6809o;length metric $120;array measured[*] hoc_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6809m;set w6809m;format value best32.;run;
proc export data=w6809m outfile="%sysfunc(pathname(work))/W6809.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6809;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6809:;quit;
