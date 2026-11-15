/* New workflow W6709; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6709i;
length gene $80;
gene='p01';raw_p=1;output;
gene='p02';raw_p=0.10016896607241221;output;
gene='p03';raw_p=0.07241712202934825;output;
gene='p04';raw_p=0.05;output;
gene='p05';raw_p=0.998371887714903;output;
gene='p06';raw_p=0.18771534458556627;output;
gene='p07';raw_p=0.01;output;
gene='p08';raw_p=0.014767900051198879;output;
run;
data w6709o;set w6709i;bon_p=min(1,8*raw_p);sid_p=1-(1-raw_p)**8;run;
data w6709m(keep=metric value);set w6709o;length metric $120;array measured[*] bon_p sid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6709m;set w6709m;format value best32.;run;
proc export data=w6709m outfile="%sysfunc(pathname(work))/W6709.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6709;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6709:;quit;
