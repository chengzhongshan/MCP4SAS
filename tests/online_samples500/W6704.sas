/* New workflow W6704; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6704i;
length gene $80;
gene='p01';raw_p=0.8;output;
gene='p02';raw_p=0.4408992477108329;output;
gene='p03';raw_p=0.1320167534464296;output;
gene='p04';raw_p=1;output;
gene='p05';raw_p=0.4514579359395511;output;
gene='p06';raw_p=0.41609167560685867;output;
gene='p07';raw_p=0.8;output;
gene='p08';raw_p=0.9101106396808636;output;
gene='p09';raw_p=0.757464995328888;output;
gene='p10';raw_p=0.8;output;
run;
data w6704o;set w6704i;bon_p=min(1,10*raw_p);sid_p=1-(1-raw_p)**10;run;
data w6704m(keep=metric value);set w6704o;length metric $120;array measured[*] bon_p sid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6704m;set w6704m;format value best32.;run;
proc export data=w6704m outfile="%sysfunc(pathname(work))/W6704.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6704;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6704:;quit;
