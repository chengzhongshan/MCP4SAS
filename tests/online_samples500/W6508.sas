/* New workflow W6508; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6508i;
n11=15;n12=57;n21=7;n22=83;output;
run;
%n26_compodds(w6508i,w6508o);run;
data w6508m(keep=metric value);set w6508o;length metric $120;array measured[*] estimate lower upper variance;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6508m;set w6508m;format value best32.;run;
proc export data=w6508m outfile="%sysfunc(pathname(work))/W6508.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6508;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6508:;quit;
