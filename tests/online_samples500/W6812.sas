/* New workflow W6812; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6812i;
length gene $80;
gene='p01';raw_p=0;output;
gene='p02';raw_p=0.0037196411766448056;output;
gene='p03';raw_p=0.840335838951799;output;
gene='p04';raw_p=0.2;output;
gene='p05';raw_p=0.2508209951119784;output;
gene='p06';raw_p=0.34549358872683444;output;
gene='p07';raw_p=0.01;output;
gene='p08';raw_p=0.7596060941794014;output;
gene='p09';raw_p=0.38756034483469937;output;
gene='p10';raw_p=0.01;output;
gene='p11';raw_p=0.3956222206216845;output;
run;
proc multtest inpvalues=w6812i hoc out=w6812o noprint;run;
data w6812m(keep=metric value);set w6812o;length metric $120;array measured[*] hoc_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6812m;set w6812m;format value best32.;run;
proc export data=w6812m outfile="%sysfunc(pathname(work))/W6812.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6812;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6812:;quit;
