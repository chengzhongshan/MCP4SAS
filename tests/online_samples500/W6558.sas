/* New workflow W6558; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6558i;
n11=25;n12=56;n21=12;n22=59;output;
n11=11;n12=39;n21=33;n22=61;output;
n11=18;n12=67;n21=28;n22=34;output;
n11=19;n12=64;n21=26;n22=26;output;
n11=43;n12=49;n21=8;n22=69;output;
n11=43;n12=77;n21=10;n22=92;output;
n11=26;n12=25;n21=8;n22=89;output;
run;
%n26_compodds(w6558i,w6558o);run;
%n26_wavgodds(w6558o,w6558pool,1,0.95);run;
data w6558m(keep=metric value);set w6558pool;length metric $120;array measured[*] estimate lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6558m;set w6558m;format value best32.;run;
proc export data=w6558m outfile="%sysfunc(pathname(work))/W6558.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6558;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6558:;quit;
