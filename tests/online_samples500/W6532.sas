/* New workflow W6532; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6532i;
n11=0;n12=77;n21=40;n22=77;output;
run;
%n26_compodds(w6532i,w6532o);run;
data w6532m(keep=metric value);set w6532o;length metric $120;array measured[*] estimate lower upper variance;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6532m;set w6532m;format value best32.;run;
proc export data=w6532m outfile="%sysfunc(pathname(work))/W6532.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6532;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6532:;quit;
