/* New workflow W6821; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6821i;
length gene $80;
gene='p01';raw_p=0;output;
gene='p02';raw_p=0.751796556307519;output;
gene='p03';raw_p=0.8776370948314074;output;
gene='p04';raw_p=0.01;output;
gene='p05';raw_p=0.4284281561585054;output;
gene='p06';raw_p=0.45706999689254535;output;
gene='p07';raw_p=0.01;output;
run;
proc multtest inpvalues=w6821i fdr out=w6821o noprint;run;
data w6821m(keep=metric value);set w6821o;length metric $120;array measured[*] fdr_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6821m;set w6821m;format value best32.;run;
proc export data=w6821m outfile="%sysfunc(pathname(work))/W6821.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6821;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6821:;quit;
