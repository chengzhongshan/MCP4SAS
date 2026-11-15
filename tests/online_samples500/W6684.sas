/* New workflow W6684; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6684i;
n11=17;n12=52;n21=25;n22=60;output;
n11=30;n12=46;n21=21;n22=65;output;
n11=40;n12=24;n21=30;n22=38;output;
n11=20;n12=34;n21=14;n22=59;output;
n11=21;n12=55;n21=6;n22=33;output;
n11=23;n12=40;n21=30;n22=72;output;
n11=20;n12=61;n21=5;n22=48;output;
run;
%n26_mhodds(w6684i,w6684o,0.8);run;
data w6684m(keep=metric value);set w6684o;length metric $120;array measured[*] estimate;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6684m;set w6684m;format value best32.;run;
proc export data=w6684m outfile="%sysfunc(pathname(work))/W6684.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6684;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6684:;quit;
