/* New workflow W6697; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6697i;
n11=33;n12=70;n21=10;n22=50;output;
n11=33;n12=67;n21=5;n22=53;output;
n11=34;n12=63;n21=10;n22=52;output;
n11=30;n12=41;n21=22;n22=63;output;
n11=26;n12=47;n21=14;n22=56;output;
n11=33;n12=67;n21=8;n22=66;output;
run;
%n26_mhodds(w6697i,w6697o,0.9);run;
data w6697m(keep=metric value);set w6697o;length metric $120;array measured[*] estimate;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6697m;set w6697m;format value best32.;run;
proc export data=w6697m outfile="%sysfunc(pathname(work))/W6697.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6697;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6697:;quit;
