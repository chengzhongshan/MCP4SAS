/* New workflow W6692; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6692i;
n11=36;n12=38;n21=11;n22=60;output;
n11=18;n12=50;n21=26;n22=31;output;
n11=15;n12=34;n21=22;n22=53;output;
n11=23;n12=69;n21=26;n22=31;output;
n11=30;n12=62;n21=23;n22=35;output;
n11=18;n12=20;n21=14;n22=35;output;
n11=35;n12=30;n21=11;n22=52;output;
n11=13;n12=25;n21=22;n22=69;output;
run;
%n26_mhodds(w6692i,w6692o,0.8);run;
data w6692m(keep=metric value);set w6692o;length metric $120;array measured[*] estimate;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6692m;set w6692m;format value best32.;run;
proc export data=w6692m outfile="%sysfunc(pathname(work))/W6692.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6692;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6692:;quit;
