/* New workflow W6552; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6552i;
n11=18;n12=90;n21=31;n22=56;output;
n11=24;n12=69;n21=10;n22=63;output;
n11=8;n12=87;n21=17;n22=26;output;
n11=30;n12=32;n21=18;n22=82;output;
n11=30;n12=55;n21=27;n22=45;output;
n11=25;n12=83;n21=38;n22=89;output;
n11=29;n12=20;n21=8;n22=77;output;
n11=19;n12=47;n21=26;n22=40;output;
run;
%n26_compodds(w6552i,w6552o);run;
%n26_wavgodds(w6552o,w6552pool,1,0.95);run;
data w6552m(keep=metric value);set w6552pool;length metric $120;array measured[*] estimate lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6552m;set w6552m;format value best32.;run;
proc export data=w6552m outfile="%sysfunc(pathname(work))/W6552.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6552;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6552:;quit;
