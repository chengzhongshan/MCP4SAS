/* New workflow W6840; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6840i;
length gene $80;
gene='p01';raw_p=0.2;output;
gene='p02';raw_p=0.5834578849643837;output;
gene='p03';raw_p=0.11350949260598009;output;
gene='p04';raw_p=0.2;output;
gene='p05';raw_p=0.45112403473565366;output;
gene='p06';raw_p=0.4873741624400689;output;
gene='p07';raw_p=0;output;
gene='p08';raw_p=0.6443946039223404;output;
gene='p09';raw_p=0.04465233651464562;output;
gene='p10';raw_p=0.2;output;
gene='p11';raw_p=0.6035223915516114;output;
gene='p12';raw_p=0.38192081647851117;output;
run;
proc multtest inpvalues=w6840i fdr out=w6840o noprint;run;
data w6840m(keep=metric value);set w6840o;length metric $120;array measured[*] fdr_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6840m;set w6840m;format value best32.;run;
proc export data=w6840m outfile="%sysfunc(pathname(work))/W6840.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6840;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6840:;quit;
