/* New workflow W6529; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6529i;
n11=0;n12=41;n21=31;n22=41;output;
run;
%n26_compodds(w6529i,w6529o);run;
data w6529m(keep=metric value);set w6529o;length metric $120;array measured[*] estimate lower upper variance;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6529m;set w6529m;format value best32.;run;
proc export data=w6529m outfile="%sysfunc(pathname(work))/W6529.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6529;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6529:;quit;
