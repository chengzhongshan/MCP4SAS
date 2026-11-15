/* New workflow W6550; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6550i;
n11=19;n12=90;n21=32;n22=52;output;
n11=16;n12=74;n21=39;n22=69;output;
n11=13;n12=33;n21=16;n22=45;output;
n11=36;n12=25;n21=38;n22=74;output;
n11=34;n12=67;n21=19;n22=66;output;
n11=35;n12=88;n21=25;n22=34;output;
run;
%n26_compodds(w6550i,w6550o);run;
%n26_wavgodds(w6550o,w6550pool,1,0.95);run;
data w6550m(keep=metric value);set w6550pool;length metric $120;array measured[*] estimate lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6550m;set w6550m;format value best32.;run;
proc export data=w6550m outfile="%sysfunc(pathname(work))/W6550.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6550;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6550:;quit;
