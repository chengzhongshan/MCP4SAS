/* New workflow W6506; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6506i;
n11=41;n12=37;n21=24;n22=80;output;
run;
%n26_compodds(w6506i,w6506o);run;
data w6506m(keep=metric value);set w6506o;length metric $120;array measured[*] estimate lower upper variance;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6506m;set w6506m;format value best32.;run;
proc export data=w6506m outfile="%sysfunc(pathname(work))/W6506.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6506;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6506:;quit;
