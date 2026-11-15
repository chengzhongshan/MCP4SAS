/* New workflow W6533; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6533i;
n11=0;n12=81;n21=30;n22=60;output;
run;
%n26_compodds(w6533i,w6533o);run;
data w6533m(keep=metric value);set w6533o;length metric $120;array measured[*] estimate lower upper variance;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6533m;set w6533m;format value best32.;run;
proc export data=w6533m outfile="%sysfunc(pathname(work))/W6533.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6533;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6533:;quit;
