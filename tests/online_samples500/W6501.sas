/* New workflow W6501; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6501i;
n11=20;n12=36;n21=12;n22=28;output;
run;
%n26_compodds(w6501i,w6501o);run;
data w6501m(keep=metric value);set w6501o;length metric $120;array measured[*] estimate lower upper variance;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6501m;set w6501m;format value best32.;run;
proc export data=w6501m outfile="%sysfunc(pathname(work))/W6501.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6501;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6501:;quit;
