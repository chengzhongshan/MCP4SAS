/* New workflow W6698; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6698i;
n11=40;n12=36;n21=9;n22=74;output;
n11=9;n12=68;n21=26;n22=61;output;
n11=34;n12=66;n21=18;n22=80;output;
n11=8;n12=23;n21=19;n22=58;output;
n11=21;n12=54;n21=26;n22=30;output;
n11=30;n12=59;n21=5;n22=33;output;
n11=16;n12=41;n21=15;n22=41;output;
run;
%n26_mhodds(w6698i,w6698o,0.95);run;
data w6698m(keep=metric value);set w6698o;length metric $120;array measured[*] estimate;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6698m;set w6698m;format value best32.;run;
proc export data=w6698m outfile="%sysfunc(pathname(work))/W6698.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6698;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6698:;quit;
