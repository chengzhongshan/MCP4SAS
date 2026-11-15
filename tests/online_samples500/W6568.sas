/* New workflow W6568; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6568i;
n11=0;n12=39;n21=9;n22=74;output;
n11=22;n12=34;n21=10;n22=39;output;
n11=12;n12=41;n21=24;n22=79;output;
n11=9;n12=23;n21=38;n22=70;output;
run;
%n26_compodds(w6568i,w6568o);run;
%n26_wavgodds(w6568o,w6568pool,3,0.8);run;
data w6568m(keep=metric value);set w6568pool;length metric $120;array measured[*] estimate lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6568m;set w6568m;format value best32.;run;
proc export data=w6568m outfile="%sysfunc(pathname(work))/W6568.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6568;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6568:;quit;
