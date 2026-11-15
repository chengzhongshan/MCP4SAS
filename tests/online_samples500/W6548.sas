/* New workflow W6548; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6548i;
n11=30;n12=90;n21=26;n22=53;output;
n11=39;n12=45;n21=13;n22=73;output;
n11=22;n12=77;n21=11;n22=42;output;
n11=39;n12=52;n21=18;n22=50;output;
run;
%n26_compodds(w6548i,w6548o);run;
%n26_wavgodds(w6548o,w6548pool,1,0.95);run;
data w6548m(keep=metric value);set w6548pool;length metric $120;array measured[*] estimate lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6548m;set w6548m;format value best32.;run;
proc export data=w6548m outfile="%sysfunc(pathname(work))/W6548.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6548;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6548:;quit;
