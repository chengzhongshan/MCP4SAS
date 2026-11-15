/* New workflow W6577; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6577i;
n11=0;n12=61;n21=8;n22=34;output;
n11=39;n12=69;n21=27;n22=91;output;
n11=21;n12=24;n21=12;n22=73;output;
n11=25;n12=61;n21=17;n22=33;output;
n11=28;n12=62;n21=25;n22=50;output;
n11=41;n12=55;n21=20;n22=36;output;
run;
%n26_compodds(w6577i,w6577o);run;
%n26_wavgodds(w6577o,w6577pool,3,0.9);run;
data w6577m(keep=metric value);set w6577pool;length metric $120;array measured[*] estimate lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6577m;set w6577m;format value best32.;run;
proc export data=w6577m outfile="%sysfunc(pathname(work))/W6577.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6577;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6577:;quit;
