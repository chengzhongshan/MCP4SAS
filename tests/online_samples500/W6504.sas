/* New workflow W6504; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6504i;
n11=33;n12=32;n21=18;n22=34;output;
run;
%n26_compodds(w6504i,w6504o);run;
data w6504m(keep=metric value);set w6504o;length metric $120;array measured[*] estimate lower upper variance;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6504m;set w6504m;format value best32.;run;
proc export data=w6504m outfile="%sysfunc(pathname(work))/W6504.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6504;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6504:;quit;
