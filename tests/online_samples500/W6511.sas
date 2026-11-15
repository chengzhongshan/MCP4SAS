/* New workflow W6511; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6511i;
n11=33;n12=87;n21=9;n22=53;output;
run;
%n26_compodds(w6511i,w6511o);run;
data w6511m(keep=metric value);set w6511o;length metric $120;array measured[*] estimate lower upper variance;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6511m;set w6511m;format value best32.;run;
proc export data=w6511m outfile="%sysfunc(pathname(work))/W6511.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6511;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6511:;quit;
