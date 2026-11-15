/* New workflow W6535; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6535i;
n11=0;n12=49;n21=28;n22=91;output;
run;
%n26_compodds(w6535i,w6535o);run;
data w6535m(keep=metric value);set w6535o;length metric $120;array measured[*] estimate lower upper variance;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6535m;set w6535m;format value best32.;run;
proc export data=w6535m outfile="%sysfunc(pathname(work))/W6535.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6535;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6535:;quit;
