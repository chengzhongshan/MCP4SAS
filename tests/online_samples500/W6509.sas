/* New workflow W6509; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6509i;
n11=36;n12=43;n21=31;n22=78;output;
run;
%n26_compodds(w6509i,w6509o);run;
data w6509m(keep=metric value);set w6509o;length metric $120;array measured[*] estimate lower upper variance;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6509m;set w6509m;format value best32.;run;
proc export data=w6509m outfile="%sysfunc(pathname(work))/W6509.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6509;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6509:;quit;
