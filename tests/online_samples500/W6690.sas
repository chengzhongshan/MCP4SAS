/* New workflow W6690; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6690i;
n11=12;n12=45;n21=15;n22=64;output;
n11=24;n12=29;n21=28;n22=58;output;
n11=17;n12=49;n21=29;n22=34;output;
n11=25;n12=24;n21=22;n22=78;output;
n11=28;n12=22;n21=23;n22=37;output;
n11=9;n12=26;n21=14;n22=38;output;
run;
%n26_mhodds(w6690i,w6690o,0.95);run;
data w6690m(keep=metric value);set w6690o;length metric $120;array measured[*] estimate;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6690m;set w6690m;format value best32.;run;
proc export data=w6690m outfile="%sysfunc(pathname(work))/W6690.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6690;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6690:;quit;
