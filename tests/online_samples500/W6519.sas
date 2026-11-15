/* New workflow W6519; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6519i;
n11=45;n12=27;n21=26;n22=49;output;
run;
%n26_compodds(w6519i,w6519o);run;
data w6519m(keep=metric value);set w6519o;length metric $120;array measured[*] estimate lower upper variance;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6519m;set w6519m;format value best32.;run;
proc export data=w6519m outfile="%sysfunc(pathname(work))/W6519.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6519;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6519:;quit;
