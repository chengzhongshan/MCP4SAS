/* New workflow W6517; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6517i;
n11=28;n12=68;n21=32;n22=65;output;
run;
%n26_compodds(w6517i,w6517o);run;
data w6517m(keep=metric value);set w6517o;length metric $120;array measured[*] estimate lower upper variance;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6517m;set w6517m;format value best32.;run;
proc export data=w6517m outfile="%sysfunc(pathname(work))/W6517.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6517;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6517:;quit;
