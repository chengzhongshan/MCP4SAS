/* New workflow W6830; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6830i;
length gene $80;
gene='p01';raw_p=0.01;output;
gene='p02';raw_p=0.2410618627221638;output;
gene='p03';raw_p=0.24579942198230142;output;
gene='p04';raw_p=0.01;output;
gene='p05';raw_p=0.9892753917535795;output;
gene='p06';raw_p=0.5171377219637825;output;
gene='p07';raw_p=0.005;output;
gene='p08';raw_p=0.8795748748653088;output;
gene='p09';raw_p=0.8082205955722606;output;
run;
proc multtest inpvalues=w6830i fdr out=w6830o noprint;run;
data w6830m(keep=metric value);set w6830o;length metric $120;array measured[*] fdr_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6830m;set w6830m;format value best32.;run;
proc export data=w6830m outfile="%sysfunc(pathname(work))/W6830.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6830;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6830:;quit;
