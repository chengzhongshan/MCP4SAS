/* New workflow W6540; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6540i;
n11=0;n12=70;n21=33;n22=33;output;
run;
%n26_compodds(w6540i,w6540o);run;
data w6540m(keep=metric value);set w6540o;length metric $120;array measured[*] estimate lower upper variance;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6540m;set w6540m;format value best32.;run;
proc export data=w6540m outfile="%sysfunc(pathname(work))/W6540.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6540;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6540:;quit;
