/* New workflow W6527; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6527i;
n11=0;n12=56;n21=14;n22=54;output;
run;
%n26_compodds(w6527i,w6527o);run;
data w6527m(keep=metric value);set w6527o;length metric $120;array measured[*] estimate lower upper variance;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6527m;set w6527m;format value best32.;run;
proc export data=w6527m outfile="%sysfunc(pathname(work))/W6527.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6527;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6527:;quit;
