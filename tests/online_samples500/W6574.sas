/* New workflow W6574; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6574i;
n11=0;n12=67;n21=16;n22=33;output;
n11=40;n12=21;n21=21;n22=58;output;
n11=39;n12=77;n21=30;n22=60;output;
run;
%n26_compodds(w6574i,w6574o);run;
%n26_wavgodds(w6574o,w6574pool,3,0.95);run;
data w6574m(keep=metric value);set w6574pool;length metric $120;array measured[*] estimate lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6574m;set w6574m;format value best32.;run;
proc export data=w6574m outfile="%sysfunc(pathname(work))/W6574.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6574;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6574:;quit;
