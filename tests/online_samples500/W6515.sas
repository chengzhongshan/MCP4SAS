/* New workflow W6515; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6515i;
n11=44;n12=45;n21=30;n22=36;output;
run;
%n26_compodds(w6515i,w6515o);run;
data w6515m(keep=metric value);set w6515o;length metric $120;array measured[*] estimate lower upper variance;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6515m;set w6515m;format value best32.;run;
proc export data=w6515m outfile="%sysfunc(pathname(work))/W6515.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6515;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6515:;quit;
