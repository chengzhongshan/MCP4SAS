/* New workflow W6703; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6703i;
length gene $80;
gene='p01';raw_p=0.05;output;
gene='p02';raw_p=0.7535997923562009;output;
gene='p03';raw_p=0.9440027385270057;output;
gene='p04';raw_p=1;output;
gene='p05';raw_p=0.11932216451206124;output;
gene='p06';raw_p=0.20148590666932387;output;
gene='p07';raw_p=0.005;output;
gene='p08';raw_p=0.4093193514179472;output;
gene='p09';raw_p=0.04770106650315431;output;
run;
data w6703o;set w6703i;bon_p=min(1,9*raw_p);sid_p=1-(1-raw_p)**9;run;
data w6703m(keep=metric value);set w6703o;length metric $120;array measured[*] bon_p sid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6703m;set w6703m;format value best32.;run;
proc export data=w6703m outfile="%sysfunc(pathname(work))/W6703.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6703;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6703:;quit;
