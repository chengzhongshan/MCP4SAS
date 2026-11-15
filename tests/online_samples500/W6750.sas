/* New workflow W6750; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6750i;
length gene $80;
gene='p01';raw_p=0.8;output;
gene='p02';raw_p=0.6539415001115304;output;
gene='p03';raw_p=0.16524315734884165;output;
gene='p04';raw_p=0.05;output;
gene='p05';raw_p=0.19564551863876645;output;
gene='p06';raw_p=0.05250649548131603;output;
gene='p07';raw_p=1e-05;output;
gene='p08';raw_p=0.20426456278706318;output;
gene='p09';raw_p=0.47273483451427245;output;
run;
proc multtest inpvalues=w6750i sid out=w6750o noprint;run;
data w6750m(keep=metric value);set w6750o;length metric $120;array measured[*] sid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6750m;set w6750m;format value best32.;run;
proc export data=w6750m outfile="%sysfunc(pathname(work))/W6750.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6750;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6750:;quit;
