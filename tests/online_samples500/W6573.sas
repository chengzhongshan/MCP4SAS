/* New workflow W6573; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6573i;
n11=0;n12=25;n21=22;n22=27;output;
n11=24;n12=63;n21=24;n22=37;output;
n11=45;n12=32;n21=18;n22=48;output;
n11=44;n12=36;n21=27;n22=62;output;
n11=16;n12=50;n21=16;n22=39;output;
n11=39;n12=62;n21=19;n22=86;output;
n11=24;n12=39;n21=31;n22=51;output;
n11=17;n12=49;n21=25;n22=92;output;
n11=9;n12=76;n21=27;n22=50;output;
run;
%n26_compodds(w6573i,w6573o);run;
%n26_wavgodds(w6573o,w6573pool,3,0.9);run;
data w6573m(keep=metric value);set w6573pool;length metric $120;array measured[*] estimate lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6573m;set w6573m;format value best32.;run;
proc export data=w6573m outfile="%sysfunc(pathname(work))/W6573.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6573;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6573:;quit;
