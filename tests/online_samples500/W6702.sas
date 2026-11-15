/* New workflow W6702; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6702i;
length gene $80;
gene='p01';raw_p=0.001;output;
gene='p02';raw_p=0.1740047887926065;output;
gene='p03';raw_p=0.20679163533299139;output;
gene='p04';raw_p=1;output;
gene='p05';raw_p=0.4282637930385358;output;
gene='p06';raw_p=0.5629894214682478;output;
gene='p07';raw_p=0.8;output;
gene='p08';raw_p=0.6611149400752254;output;
run;
data w6702o;set w6702i;bon_p=min(1,8*raw_p);sid_p=1-(1-raw_p)**8;run;
data w6702m(keep=metric value);set w6702o;length metric $120;array measured[*] bon_p sid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6702m;set w6702m;format value best32.;run;
proc export data=w6702m outfile="%sysfunc(pathname(work))/W6702.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6702;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6702:;quit;
