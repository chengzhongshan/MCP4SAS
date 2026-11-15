/* New workflow W6742; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6742i;
length gene $80;
gene='p01';raw_p=0.8;output;
gene='p02';raw_p=0.45535612156488736;output;
gene='p03';raw_p=0.3157585502766096;output;
gene='p04';raw_p=0.8;output;
gene='p05';raw_p=0.38942426574544053;output;
gene='p06';raw_p=0.46396384301239557;output;
gene='p07';raw_p=1e-05;output;
gene='p08';raw_p=0.8370948124659396;output;
run;
proc multtest inpvalues=w6742i sid out=w6742o noprint;run;
data w6742m(keep=metric value);set w6742o;length metric $120;array measured[*] sid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6742m;set w6742m;format value best32.;run;
proc export data=w6742m outfile="%sysfunc(pathname(work))/W6742.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6742;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6742:;quit;
