/* New workflow W6826; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6826i;
length gene $80;
gene='p01';raw_p=1e-05;output;
gene='p02';raw_p=0.4142915734916487;output;
gene='p03';raw_p=0.19438024072196414;output;
gene='p04';raw_p=0.005;output;
gene='p05';raw_p=0.4713633478217102;output;
gene='p06';raw_p=0.686986883901636;output;
gene='p07';raw_p=1;output;
gene='p08';raw_p=0.10496976803583946;output;
gene='p09';raw_p=0.7685758154084097;output;
gene='p10';raw_p=0.001;output;
gene='p11';raw_p=0.7131903650253163;output;
gene='p12';raw_p=0.6363744591833537;output;
run;
proc multtest inpvalues=w6826i fdr out=w6826o noprint;run;
data w6826m(keep=metric value);set w6826o;length metric $120;array measured[*] fdr_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6826m;set w6826m;format value best32.;run;
proc export data=w6826m outfile="%sysfunc(pathname(work))/W6826.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6826;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6826:;quit;
