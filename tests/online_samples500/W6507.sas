/* New workflow W6507; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6507i;
n11=19;n12=40;n21=40;n22=43;output;
run;
%n26_compodds(w6507i,w6507o);run;
data w6507m(keep=metric value);set w6507o;length metric $120;array measured[*] estimate lower upper variance;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6507m;set w6507m;format value best32.;run;
proc export data=w6507m outfile="%sysfunc(pathname(work))/W6507.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6507;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6507:;quit;
