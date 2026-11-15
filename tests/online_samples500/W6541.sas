/* New workflow W6541; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6541i;
n11=9;n12=38;n21=23;n22=66;output;
n11=36;n12=40;n21=9;n22=64;output;
n11=19;n12=53;n21=25;n22=39;output;
n11=14;n12=54;n21=18;n22=54;output;
run;
%n26_compodds(w6541i,w6541o);run;
%n26_wavgodds(w6541o,w6541pool,1,0.95);run;
data w6541m(keep=metric value);set w6541pool;length metric $120;array measured[*] estimate lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6541m;set w6541m;format value best32.;run;
proc export data=w6541m outfile="%sysfunc(pathname(work))/W6541.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6541;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6541:;quit;
