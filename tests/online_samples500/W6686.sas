/* New workflow W6686; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6686i;
n11=8;n12=44;n21=17;n22=46;output;
n11=11;n12=30;n21=28;n22=55;output;
n11=10;n12=22;n21=9;n22=52;output;
n11=21;n12=58;n21=25;n22=39;output;
n11=20;n12=41;n21=22;n22=53;output;
n11=26;n12=66;n21=28;n22=34;output;
n11=29;n12=41;n21=20;n22=66;output;
n11=28;n12=61;n21=13;n22=52;output;
n11=16;n12=50;n21=18;n22=50;output;
run;
%n26_mhodds(w6686i,w6686o,0.95);run;
data w6686m(keep=metric value);set w6686o;length metric $120;array measured[*] estimate;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6686m;set w6686m;format value best32.;run;
proc export data=w6686m outfile="%sysfunc(pathname(work))/W6686.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6686;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6686:;quit;
