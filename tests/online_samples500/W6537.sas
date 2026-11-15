/* New workflow W6537; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6537i;
n11=0;n12=52;n21=37;n22=31;output;
run;
%n26_compodds(w6537i,w6537o);run;
data w6537m(keep=metric value);set w6537o;length metric $120;array measured[*] estimate lower upper variance;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6537m;set w6537m;format value best32.;run;
proc export data=w6537m outfile="%sysfunc(pathname(work))/W6537.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6537;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6537:;quit;
