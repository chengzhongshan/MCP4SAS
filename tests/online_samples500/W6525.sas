/* New workflow W6525; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6525i;
n11=0;n12=53;n21=21;n22=92;output;
run;
%n26_compodds(w6525i,w6525o);run;
data w6525m(keep=metric value);set w6525o;length metric $120;array measured[*] estimate lower upper variance;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6525m;set w6525m;format value best32.;run;
proc export data=w6525m outfile="%sysfunc(pathname(work))/W6525.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6525;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6525:;quit;
