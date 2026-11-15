/* New workflow W6691; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6691i;
n11=34;n12=34;n21=10;n22=73;output;
n11=36;n12=59;n21=16;n22=30;output;
n11=32;n12=37;n21=15;n22=74;output;
n11=18;n12=56;n21=16;n22=62;output;
n11=37;n12=55;n21=20;n22=79;output;
n11=16;n12=43;n21=13;n22=44;output;
n11=31;n12=22;n21=10;n22=39;output;
run;
%n26_mhodds(w6691i,w6691o,0.99);run;
data w6691m(keep=metric value);set w6691o;length metric $120;array measured[*] estimate;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6691m;set w6691m;format value best32.;run;
proc export data=w6691m outfile="%sysfunc(pathname(work))/W6691.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6691;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6691:;quit;
