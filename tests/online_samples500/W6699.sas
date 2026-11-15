/* New workflow W6699; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6699i;
n11=35;n12=66;n21=8;n22=77;output;
n11=23;n12=53;n21=12;n22=62;output;
n11=8;n12=57;n21=16;n22=55;output;
n11=36;n12=28;n21=5;n22=70;output;
n11=15;n12=21;n21=25;n22=34;output;
n11=36;n12=57;n21=6;n22=67;output;
n11=24;n12=30;n21=6;n22=51;output;
n11=17;n12=70;n21=14;n22=52;output;
run;
%n26_mhodds(w6699i,w6699o,0.99);run;
data w6699m(keep=metric value);set w6699o;length metric $120;array measured[*] estimate;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6699m;set w6699m;format value best32.;run;
proc export data=w6699m outfile="%sysfunc(pathname(work))/W6699.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6699;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6699:;quit;
