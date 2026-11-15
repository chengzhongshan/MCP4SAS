/* New workflow W6700; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6700i;
n11=12;n12=68;n21=27;n22=51;output;
n11=8;n12=61;n21=7;n22=38;output;
n11=9;n12=62;n21=10;n22=70;output;
n11=15;n12=46;n21=14;n22=30;output;
n11=26;n12=39;n21=8;n22=42;output;
n11=13;n12=53;n21=6;n22=63;output;
n11=20;n12=52;n21=14;n22=47;output;
n11=12;n12=35;n21=7;n22=77;output;
n11=26;n12=25;n21=6;n22=32;output;
run;
%n26_mhodds(w6700i,w6700o,0.8);run;
data w6700m(keep=metric value);set w6700o;length metric $120;array measured[*] estimate;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6700m;set w6700m;format value best32.;run;
proc export data=w6700m outfile="%sysfunc(pathname(work))/W6700.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6700;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6700:;quit;
