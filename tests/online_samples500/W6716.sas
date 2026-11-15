/* New workflow W6716; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6716i;
length gene $80;
gene='p01';raw_p=0.2;output;
gene='p02';raw_p=0.22649592535279062;output;
gene='p03';raw_p=0.46763551513306123;output;
gene='p04';raw_p=0.01;output;
gene='p05';raw_p=0.30669716927919854;output;
gene='p06';raw_p=0.4476036071212982;output;
gene='p07';raw_p=0.01;output;
gene='p08';raw_p=0.5548478849528138;output;
run;
data w6716o;set w6716i;bon_p=min(1,8*raw_p);sid_p=1-(1-raw_p)**8;run;
data w6716m(keep=metric value);set w6716o;length metric $120;array measured[*] bon_p sid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6716m;set w6716m;format value best32.;run;
proc export data=w6716m outfile="%sysfunc(pathname(work))/W6716.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6716;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6716:;quit;
