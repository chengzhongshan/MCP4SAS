/* New workflow W6556; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6556i;
n11=23;n12=78;n21=23;n22=48;output;
n11=27;n12=42;n21=9;n22=42;output;
n11=43;n12=80;n21=24;n22=92;output;
n11=30;n12=84;n21=29;n22=36;output;
n11=19;n12=48;n21=17;n22=83;output;
run;
%n26_compodds(w6556i,w6556o);run;
%n26_wavgodds(w6556o,w6556pool,1,0.95);run;
data w6556m(keep=metric value);set w6556pool;length metric $120;array measured[*] estimate lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6556m;set w6556m;format value best32.;run;
proc export data=w6556m outfile="%sysfunc(pathname(work))/W6556.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6556;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6556:;quit;
