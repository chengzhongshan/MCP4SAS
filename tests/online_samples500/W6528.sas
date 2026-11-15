/* New workflow W6528; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6528i;
n11=0;n12=47;n21=38;n22=69;output;
run;
%n26_compodds(w6528i,w6528o);run;
data w6528m(keep=metric value);set w6528o;length metric $120;array measured[*] estimate lower upper variance;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6528m;set w6528m;format value best32.;run;
proc export data=w6528m outfile="%sysfunc(pathname(work))/W6528.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6528;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6528:;quit;
