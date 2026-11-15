/* New workflow W6765; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6765i;
length gene $80;
gene='p01';raw_p=0.8;output;
gene='p02';raw_p=0.025076171540274306;output;
gene='p03';raw_p=0.7531643518685532;output;
gene='p04';raw_p=1e-05;output;
gene='p05';raw_p=0.9092117882842374;output;
gene='p06';raw_p=0.8876630861579926;output;
gene='p07';raw_p=0.001;output;
gene='p08';raw_p=0.48453229666368447;output;
gene='p09';raw_p=0.31714049392081434;output;
gene='p10';raw_p=0.05;output;
gene='p11';raw_p=0.75344521129807;output;
run;
proc multtest inpvalues=w6765i holm out=w6765o noprint;run;
data w6765m(keep=metric value);set w6765o;length metric $120;array measured[*] stpbon_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6765m;set w6765m;format value best32.;run;
proc export data=w6765m outfile="%sysfunc(pathname(work))/W6765.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6765;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6765:;quit;
