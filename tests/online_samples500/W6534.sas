/* New workflow W6534; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6534i;
n11=0;n12=62;n21=23;n22=45;output;
run;
%n26_compodds(w6534i,w6534o);run;
data w6534m(keep=metric value);set w6534o;length metric $120;array measured[*] estimate lower upper variance;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6534m;set w6534m;format value best32.;run;
proc export data=w6534m outfile="%sysfunc(pathname(work))/W6534.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6534;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6534:;quit;
