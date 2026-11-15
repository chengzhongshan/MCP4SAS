/* New workflow W6557; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6557i;
n11=21;n12=65;n21=9;n22=50;output;
n11=15;n12=86;n21=10;n22=76;output;
n11=8;n12=36;n21=8;n22=76;output;
n11=8;n12=40;n21=24;n22=29;output;
n11=14;n12=60;n21=10;n22=34;output;
n11=25;n12=28;n21=7;n22=37;output;
run;
%n26_compodds(w6557i,w6557o);run;
%n26_wavgodds(w6557o,w6557pool,1,0.95);run;
data w6557m(keep=metric value);set w6557pool;length metric $120;array measured[*] estimate lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6557m;set w6557m;format value best32.;run;
proc export data=w6557m outfile="%sysfunc(pathname(work))/W6557.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6557;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6557:;quit;
