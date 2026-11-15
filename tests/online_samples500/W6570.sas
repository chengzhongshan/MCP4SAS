/* New workflow W6570; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6570i;
n11=0;n12=40;n21=13;n22=83;output;
n11=12;n12=44;n21=32;n22=67;output;
n11=19;n12=87;n21=20;n22=79;output;
n11=22;n12=63;n21=40;n22=33;output;
n11=41;n12=21;n21=18;n22=77;output;
n11=35;n12=55;n21=16;n22=76;output;
run;
%n26_compodds(w6570i,w6570o);run;
%n26_wavgodds(w6570o,w6570pool,3,0.95);run;
data w6570m(keep=metric value);set w6570pool;length metric $120;array measured[*] estimate lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6570m;set w6570m;format value best32.;run;
proc export data=w6570m outfile="%sysfunc(pathname(work))/W6570.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6570;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6570:;quit;
