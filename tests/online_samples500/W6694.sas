/* New workflow W6694; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6694i;
n11=14;n12=50;n21=23;n22=62;output;
n11=13;n12=22;n21=25;n22=59;output;
n11=30;n12=66;n21=5;n22=61;output;
run;
%n26_mhodds(w6694i,w6694o,0.95);run;
data w6694m(keep=metric value);set w6694o;length metric $120;array measured[*] estimate;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6694m;set w6694m;format value best32.;run;
proc export data=w6694m outfile="%sysfunc(pathname(work))/W6694.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6694;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6694:;quit;
