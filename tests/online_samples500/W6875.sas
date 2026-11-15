/* New workflow W6875; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6875i;
length gene $80;
gene='p01';raw_p=0.001;output;
gene='p02';raw_p=0.13277485051066584;output;
gene='p03';raw_p=0.25646463079167026;output;
gene='p04';raw_p=0;output;
gene='p05';raw_p=0.2705626733029236;output;
gene='p06';raw_p=0.21716863186037627;output;
gene='p07';raw_p=1;output;
run;
data w6875o;set w6875i;retain adjusted 0;adjusted=max(adjusted,raw_p);run;
data w6875m(keep=metric value);set w6875o;length metric $120;array measured[*] adjusted;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6875m;set w6875m;format value best32.;run;
proc export data=w6875m outfile="%sysfunc(pathname(work))/W6875.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6875;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6875:;quit;
