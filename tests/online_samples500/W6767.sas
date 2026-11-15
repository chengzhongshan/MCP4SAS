/* New workflow W6767; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6767i;
length gene $80;
gene='p01';raw_p=1;output;
gene='p02';raw_p=0.682997848270448;output;
gene='p03';raw_p=0.08497166409766432;output;
gene='p04';raw_p=0.001;output;
gene='p05';raw_p=0.05893189098650031;output;
gene='p06';raw_p=0.34479310771208715;output;
run;
proc multtest inpvalues=w6767i holm out=w6767o noprint;run;
data w6767m(keep=metric value);set w6767o;length metric $120;array measured[*] stpbon_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6767m;set w6767m;format value best32.;run;
proc export data=w6767m outfile="%sysfunc(pathname(work))/W6767.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6767;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6767:;quit;
