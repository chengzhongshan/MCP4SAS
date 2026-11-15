/* New workflow W6794; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6794i;
length gene $80;
gene='p01';raw_p=0;output;
gene='p02';raw_p=0.22015764600114152;output;
gene='p03';raw_p=0.736017660980009;output;
gene='p04';raw_p=0.01;output;
gene='p05';raw_p=0.7131654486025868;output;
gene='p06';raw_p=0.05020978882399496;output;
run;
proc multtest inpvalues=w6794i stepsid out=w6794o noprint;run;
data w6794m(keep=metric value);set w6794o;length metric $120;array measured[*] stpsid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6794m;set w6794m;format value best32.;run;
proc export data=w6794m outfile="%sysfunc(pathname(work))/W6794.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6794;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6794:;quit;
