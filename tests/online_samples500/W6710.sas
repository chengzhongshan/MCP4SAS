/* New workflow W6710; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6710i;
length gene $80;
gene='p01';raw_p=0.8;output;
gene='p02';raw_p=0.43861263484113366;output;
gene='p03';raw_p=0.6310813852192246;output;
gene='p04';raw_p=1e-05;output;
gene='p05';raw_p=0.28564341139855287;output;
gene='p06';raw_p=0.5737832397814838;output;
gene='p07';raw_p=0.005;output;
gene='p08';raw_p=0.15422685011471837;output;
gene='p09';raw_p=0.034241453125925636;output;
run;
data w6710o;set w6710i;bon_p=min(1,9*raw_p);sid_p=1-(1-raw_p)**9;run;
data w6710m(keep=metric value);set w6710o;length metric $120;array measured[*] bon_p sid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6710m;set w6710m;format value best32.;run;
proc export data=w6710m outfile="%sysfunc(pathname(work))/W6710.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6710;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6710:;quit;
