/* New workflow W6575; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6575i;
n11=0;n12=61;n21=24;n22=26;output;
n11=20;n12=73;n21=36;n22=90;output;
n11=9;n12=69;n21=16;n22=34;output;
n11=35;n12=51;n21=38;n22=56;output;
run;
%n26_compodds(w6575i,w6575o);run;
%n26_wavgodds(w6575o,w6575pool,3,0.99);run;
data w6575m(keep=metric value);set w6575pool;length metric $120;array measured[*] estimate lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6575m;set w6575m;format value best32.;run;
proc export data=w6575m outfile="%sysfunc(pathname(work))/W6575.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6575;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6575:;quit;
