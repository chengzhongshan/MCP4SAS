/* New workflow W6555; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6555i;
n11=22;n12=36;n21=33;n22=39;output;
n11=15;n12=75;n21=15;n22=52;output;
n11=30;n12=40;n21=14;n22=32;output;
n11=42;n12=53;n21=7;n22=66;output;
run;
%n26_compodds(w6555i,w6555o);run;
%n26_wavgodds(w6555o,w6555pool,1,0.95);run;
data w6555m(keep=metric value);set w6555pool;length metric $120;array measured[*] estimate lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6555m;set w6555m;format value best32.;run;
proc export data=w6555m outfile="%sysfunc(pathname(work))/W6555.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6555;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6555:;quit;
