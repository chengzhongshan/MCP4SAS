/* New workflow W6804; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6804i;
length gene $80;
gene='p01';raw_p=0.005;output;
gene='p02';raw_p=0.011835779022650761;output;
gene='p03';raw_p=0.9192207820830672;output;
gene='p04';raw_p=0.01;output;
gene='p05';raw_p=0.6828591824032954;output;
gene='p06';raw_p=0.41888832231203754;output;
gene='p07';raw_p=0.001;output;
gene='p08';raw_p=0.05880805787020982;output;
gene='p09';raw_p=0.9216762144042041;output;
gene='p10';raw_p=0.005;output;
run;
proc multtest inpvalues=w6804i hoc out=w6804o noprint;run;
data w6804m(keep=metric value);set w6804o;length metric $120;array measured[*] hoc_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6804m;set w6804m;format value best32.;run;
proc export data=w6804m outfile="%sysfunc(pathname(work))/W6804.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6804;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6804:;quit;
