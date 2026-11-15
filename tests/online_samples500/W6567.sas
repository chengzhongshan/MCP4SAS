/* New workflow W6567; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6567i;
n11=0;n12=77;n21=34;n22=74;output;
n11=14;n12=86;n21=30;n22=86;output;
n11=35;n12=57;n21=38;n22=88;output;
run;
%n26_compodds(w6567i,w6567o);run;
%n26_wavgodds(w6567o,w6567pool,3,0.99);run;
data w6567m(keep=metric value);set w6567pool;length metric $120;array measured[*] estimate lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6567m;set w6567m;format value best32.;run;
proc export data=w6567m outfile="%sysfunc(pathname(work))/W6567.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6567;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6567:;quit;
