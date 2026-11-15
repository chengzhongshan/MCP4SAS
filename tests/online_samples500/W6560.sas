/* New workflow W6560; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6560i;
n11=40;n12=69;n21=20;n22=30;output;
n11=24;n12=42;n21=26;n22=47;output;
n11=40;n12=49;n21=28;n22=28;output;
n11=37;n12=51;n21=38;n22=65;output;
n11=19;n12=73;n21=14;n22=89;output;
n11=23;n12=25;n21=39;n22=31;output;
n11=23;n12=28;n21=39;n22=30;output;
n11=26;n12=31;n21=10;n22=65;output;
n11=14;n12=38;n21=40;n22=60;output;
run;
%n26_compodds(w6560i,w6560o);run;
%n26_wavgodds(w6560o,w6560pool,1,0.95);run;
data w6560m(keep=metric value);set w6560pool;length metric $120;array measured[*] estimate lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6560m;set w6560m;format value best32.;run;
proc export data=w6560m outfile="%sysfunc(pathname(work))/W6560.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6560;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6560:;quit;
