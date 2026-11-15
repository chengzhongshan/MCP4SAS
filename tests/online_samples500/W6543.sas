/* New workflow W6543; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6543i;
n11=30;n12=27;n21=26;n22=41;output;
n11=18;n12=31;n21=24;n22=38;output;
n11=35;n12=67;n21=29;n22=36;output;
n11=17;n12=60;n21=19;n22=32;output;
n11=35;n12=27;n21=26;n22=28;output;
n11=10;n12=23;n21=10;n22=62;output;
run;
%n26_compodds(w6543i,w6543o);run;
%n26_wavgodds(w6543o,w6543pool,1,0.95);run;
data w6543m(keep=metric value);set w6543pool;length metric $120;array measured[*] estimate lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6543m;set w6543m;format value best32.;run;
proc export data=w6543m outfile="%sysfunc(pathname(work))/W6543.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6543;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6543:;quit;
