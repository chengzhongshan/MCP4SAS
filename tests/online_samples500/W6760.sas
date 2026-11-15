/* New workflow W6760; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6760i;
length gene $80;
gene='p01';raw_p=1;output;
gene='p02';raw_p=0.031500870445156925;output;
gene='p03';raw_p=0.9264862456031706;output;
gene='p04';raw_p=0.8;output;
gene='p05';raw_p=0.8891604537514296;output;
gene='p06';raw_p=0.2902664397808802;output;
gene='p07';raw_p=0.001;output;
gene='p08';raw_p=0.30579905865861035;output;
gene='p09';raw_p=0.43947484486059707;output;
gene='p10';raw_p=0.2;output;
gene='p11';raw_p=0.5864282613453001;output;
gene='p12';raw_p=0.80792648853929;output;
run;
proc multtest inpvalues=w6760i sid out=w6760o noprint;run;
data w6760m(keep=metric value);set w6760o;length metric $120;array measured[*] sid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6760m;set w6760m;format value best32.;run;
proc export data=w6760m outfile="%sysfunc(pathname(work))/W6760.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6760;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6760:;quit;
