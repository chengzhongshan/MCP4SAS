/* New workflow W6681; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6681i;
n11=20;n12=51;n21=21;n22=38;output;
n11=17;n12=44;n21=21;n22=36;output;
n11=21;n12=26;n21=28;n22=42;output;
n11=30;n12=56;n21=19;n22=72;output;
run;
%n26_mhodds(w6681i,w6681o,0.9);run;
data w6681m(keep=metric value);set w6681o;length metric $120;array measured[*] estimate;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6681m;set w6681m;format value best32.;run;
proc export data=w6681m outfile="%sysfunc(pathname(work))/W6681.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6681;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6681:;quit;
