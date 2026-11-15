/* New workflow W6771; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6771i;
length gene $80;
gene='p01';raw_p=0.8;output;
gene='p02';raw_p=0.8831413477281317;output;
gene='p03';raw_p=0.18333936220998825;output;
gene='p04';raw_p=0.005;output;
gene='p05';raw_p=0.1140920844113894;output;
gene='p06';raw_p=0.3996309790184007;output;
gene='p07';raw_p=0;output;
gene='p08';raw_p=0.25658788783786235;output;
gene='p09';raw_p=0.5371224839174794;output;
gene='p10';raw_p=0.2;output;
run;
proc multtest inpvalues=w6771i holm out=w6771o noprint;run;
data w6771m(keep=metric value);set w6771o;length metric $120;array measured[*] stpbon_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6771m;set w6771m;format value best32.;run;
proc export data=w6771m outfile="%sysfunc(pathname(work))/W6771.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6771;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6771:;quit;
