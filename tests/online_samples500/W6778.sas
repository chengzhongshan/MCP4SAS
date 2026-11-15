/* New workflow W6778; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6778i;
length gene $80;
gene='p01';raw_p=0.01;output;
gene='p02';raw_p=0.9610965669908644;output;
gene='p03';raw_p=0.27351392047308;output;
gene='p04';raw_p=0.2;output;
gene='p05';raw_p=0.054896088242507024;output;
gene='p06';raw_p=0.020334692440051816;output;
gene='p07';raw_p=0.005;output;
gene='p08';raw_p=0.7823789762865107;output;
gene='p09';raw_p=0.528441012060721;output;
gene='p10';raw_p=0.001;output;
run;
proc multtest inpvalues=w6778i holm out=w6778o noprint;run;
data w6778m(keep=metric value);set w6778o;length metric $120;array measured[*] stpbon_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6778m;set w6778m;format value best32.;run;
proc export data=w6778m outfile="%sysfunc(pathname(work))/W6778.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6778;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6778:;quit;
