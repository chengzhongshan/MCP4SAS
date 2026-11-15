/* New workflow W6539; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6539i;
n11=0;n12=85;n21=17;n22=74;output;
run;
%n26_compodds(w6539i,w6539o);run;
data w6539m(keep=metric value);set w6539o;length metric $120;array measured[*] estimate lower upper variance;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6539m;set w6539m;format value best32.;run;
proc export data=w6539m outfile="%sysfunc(pathname(work))/W6539.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6539;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6539:;quit;
