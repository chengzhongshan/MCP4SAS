/* New workflow W6569; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6569i;
n11=0;n12=42;n21=13;n22=95;output;
n11=8;n12=33;n21=36;n22=72;output;
n11=12;n12=69;n21=26;n22=41;output;
n11=18;n12=74;n21=36;n22=67;output;
n11=24;n12=79;n21=23;n22=69;output;
run;
%n26_compodds(w6569i,w6569o);run;
%n26_wavgodds(w6569o,w6569pool,3,0.9);run;
data w6569m(keep=metric value);set w6569pool;length metric $120;array measured[*] estimate lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6569m;set w6569m;format value best32.;run;
proc export data=w6569m outfile="%sysfunc(pathname(work))/W6569.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6569;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6569:;quit;
