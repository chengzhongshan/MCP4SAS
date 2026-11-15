/* New workflow W6578; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6578i;
n11=0;n12=76;n21=22;n22=34;output;
n11=25;n12=78;n21=18;n22=91;output;
n11=30;n12=76;n21=7;n22=36;output;
n11=14;n12=50;n21=16;n22=64;output;
n11=43;n12=49;n21=32;n22=71;output;
n11=25;n12=76;n21=14;n22=89;output;
n11=45;n12=88;n21=18;n22=65;output;
run;
%n26_compodds(w6578i,w6578o);run;
%n26_wavgodds(w6578o,w6578pool,3,0.95);run;
data w6578m(keep=metric value);set w6578pool;length metric $120;array measured[*] estimate lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6578m;set w6578m;format value best32.;run;
proc export data=w6578m outfile="%sysfunc(pathname(work))/W6578.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6578;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6578:;quit;
