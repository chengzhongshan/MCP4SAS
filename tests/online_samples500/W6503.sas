/* New workflow W6503; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6503i;
n11=27;n12=28;n21=9;n22=86;output;
run;
%n26_compodds(w6503i,w6503o);run;
data w6503m(keep=metric value);set w6503o;length metric $120;array measured[*] estimate lower upper variance;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6503m;set w6503m;format value best32.;run;
proc export data=w6503m outfile="%sysfunc(pathname(work))/W6503.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6503;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6503:;quit;
