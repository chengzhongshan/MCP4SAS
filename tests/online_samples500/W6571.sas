/* New workflow W6571; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6571i;
n11=0;n12=79;n21=24;n22=51;output;
n11=18;n12=24;n21=36;n22=72;output;
n11=24;n12=25;n21=38;n22=50;output;
n11=29;n12=89;n21=12;n22=88;output;
n11=13;n12=46;n21=7;n22=55;output;
n11=29;n12=32;n21=33;n22=41;output;
n11=37;n12=24;n21=29;n22=94;output;
run;
%n26_compodds(w6571i,w6571o);run;
%n26_wavgodds(w6571o,w6571pool,3,0.99);run;
data w6571m(keep=metric value);set w6571pool;length metric $120;array measured[*] estimate lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6571m;set w6571m;format value best32.;run;
proc export data=w6571m outfile="%sysfunc(pathname(work))/W6571.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6571;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6571:;quit;
