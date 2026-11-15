/* New workflow W6814; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6814i;
length gene $80;
gene='p01';raw_p=0.05;output;
gene='p02';raw_p=0.6921795842853004;output;
gene='p03';raw_p=0.0745018247590129;output;
gene='p04';raw_p=1e-05;output;
gene='p05';raw_p=0.48026684258437113;output;
gene='p06';raw_p=0.33010994597615917;output;
run;
proc multtest inpvalues=w6814i hoc out=w6814o noprint;run;
data w6814m(keep=metric value);set w6814o;length metric $120;array measured[*] hoc_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6814m;set w6814m;format value best32.;run;
proc export data=w6814m outfile="%sysfunc(pathname(work))/W6814.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6814;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6814:;quit;
