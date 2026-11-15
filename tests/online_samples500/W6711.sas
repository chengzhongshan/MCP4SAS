/* New workflow W6711; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6711i;
length gene $80;
gene='p01';raw_p=0.005;output;
gene='p02';raw_p=0.2867721712958521;output;
gene='p03';raw_p=0.9772030316382958;output;
gene='p04';raw_p=0;output;
gene='p05';raw_p=0.21355805007773776;output;
gene='p06';raw_p=0.30008016119807435;output;
gene='p07';raw_p=0.05;output;
gene='p08';raw_p=0.5476820740453334;output;
gene='p09';raw_p=0.7391053877934748;output;
gene='p10';raw_p=0.001;output;
run;
data w6711o;set w6711i;bon_p=min(1,10*raw_p);sid_p=1-(1-raw_p)**10;run;
data w6711m(keep=metric value);set w6711o;length metric $120;array measured[*] bon_p sid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6711m;set w6711m;format value best32.;run;
proc export data=w6711m outfile="%sysfunc(pathname(work))/W6711.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6711;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6711:;quit;
