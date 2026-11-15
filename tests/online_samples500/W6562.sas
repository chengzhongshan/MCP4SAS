/* New workflow W6562; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6562i;
n11=0;n12=49;n21=14;n22=55;output;
n11=19;n12=39;n21=34;n22=78;output;
n11=10;n12=20;n21=24;n22=51;output;
n11=21;n12=38;n21=15;n22=36;output;
n11=16;n12=72;n21=36;n22=62;output;
run;
%n26_compodds(w6562i,w6562o);run;
%n26_wavgodds(w6562o,w6562pool,3,0.95);run;
data w6562m(keep=metric value);set w6562pool;length metric $120;array measured[*] estimate lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6562m;set w6562m;format value best32.;run;
proc export data=w6562m outfile="%sysfunc(pathname(work))/W6562.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6562;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6562:;quit;
