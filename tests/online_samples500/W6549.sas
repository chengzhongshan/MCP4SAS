/* New workflow W6549; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6549i;
n11=37;n12=82;n21=24;n22=41;output;
n11=25;n12=72;n21=21;n22=32;output;
n11=12;n12=41;n21=34;n22=44;output;
n11=43;n12=20;n21=12;n22=40;output;
n11=11;n12=51;n21=23;n22=35;output;
run;
%n26_compodds(w6549i,w6549o);run;
%n26_wavgodds(w6549o,w6549pool,1,0.95);run;
data w6549m(keep=metric value);set w6549pool;length metric $120;array measured[*] estimate lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6549m;set w6549m;format value best32.;run;
proc export data=w6549m outfile="%sysfunc(pathname(work))/W6549.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6549;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6549:;quit;
