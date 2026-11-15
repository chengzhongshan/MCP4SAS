/* New workflow W6689; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6689i;
n11=39;n12=56;n21=20;n22=50;output;
n11=10;n12=38;n21=19;n22=54;output;
n11=8;n12=57;n21=14;n22=47;output;
n11=32;n12=50;n21=16;n22=30;output;
n11=34;n12=35;n21=27;n22=71;output;
run;
%n26_mhodds(w6689i,w6689o,0.9);run;
data w6689m(keep=metric value);set w6689o;length metric $120;array measured[*] estimate;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6689m;set w6689m;format value best32.;run;
proc export data=w6689m outfile="%sysfunc(pathname(work))/W6689.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6689;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6689:;quit;
