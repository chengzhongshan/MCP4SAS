/* New workflow W6510; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6510i;
n11=31;n12=47;n21=21;n22=43;output;
run;
%n26_compodds(w6510i,w6510o);run;
data w6510m(keep=metric value);set w6510o;length metric $120;array measured[*] estimate lower upper variance;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6510m;set w6510m;format value best32.;run;
proc export data=w6510m outfile="%sysfunc(pathname(work))/W6510.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6510;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6510:;quit;
