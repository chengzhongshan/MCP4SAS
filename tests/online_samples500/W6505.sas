/* New workflow W6505; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6505i;
n11=16;n12=37;n21=17;n22=63;output;
run;
%n26_compodds(w6505i,w6505o);run;
data w6505m(keep=metric value);set w6505o;length metric $120;array measured[*] estimate lower upper variance;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6505m;set w6505m;format value best32.;run;
proc export data=w6505m outfile="%sysfunc(pathname(work))/W6505.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6505;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6505:;quit;
