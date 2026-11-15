/* New workflow W6553; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6553i;
n11=28;n12=88;n21=15;n22=61;output;
n11=8;n12=73;n21=34;n22=42;output;
n11=44;n12=81;n21=22;n22=28;output;
n11=41;n12=78;n21=15;n22=63;output;
n11=42;n12=63;n21=39;n22=27;output;
n11=33;n12=25;n21=32;n22=74;output;
n11=20;n12=79;n21=24;n22=34;output;
n11=31;n12=37;n21=10;n22=75;output;
n11=40;n12=48;n21=12;n22=81;output;
run;
%n26_compodds(w6553i,w6553o);run;
%n26_wavgodds(w6553o,w6553pool,1,0.95);run;
data w6553m(keep=metric value);set w6553pool;length metric $120;array measured[*] estimate lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6553m;set w6553m;format value best32.;run;
proc export data=w6553m outfile="%sysfunc(pathname(work))/W6553.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6553;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6553:;quit;
