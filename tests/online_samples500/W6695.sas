/* New workflow W6695; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6695i;
n11=11;n12=40;n21=22;n22=64;output;
n11=32;n12=62;n21=7;n22=41;output;
n11=20;n12=33;n21=6;n22=33;output;
n11=40;n12=43;n21=10;n22=77;output;
run;
%n26_mhodds(w6695i,w6695o,0.99);run;
data w6695m(keep=metric value);set w6695o;length metric $120;array measured[*] estimate;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6695m;set w6695m;format value best32.;run;
proc export data=w6695m outfile="%sysfunc(pathname(work))/W6695.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6695;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6695:;quit;
