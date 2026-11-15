/* New workflow W6687; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6687i;
n11=19;n12=23;n21=8;n22=52;output;
n11=9;n12=25;n21=5;n22=53;output;
n11=18;n12=49;n21=5;n22=75;output;
run;
%n26_mhodds(w6687i,w6687o,0.99);run;
data w6687m(keep=metric value);set w6687o;length metric $120;array measured[*] estimate;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6687m;set w6687m;format value best32.;run;
proc export data=w6687m outfile="%sysfunc(pathname(work))/W6687.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6687;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6687:;quit;
