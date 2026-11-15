/* New workflow W6547; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6547i;
n11=28;n12=87;n21=24;n22=59;output;
n11=26;n12=57;n21=27;n22=91;output;
n11=45;n12=27;n21=14;n22=76;output;
run;
%n26_compodds(w6547i,w6547o);run;
%n26_wavgodds(w6547o,w6547pool,1,0.95);run;
data w6547m(keep=metric value);set w6547pool;length metric $120;array measured[*] estimate lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6547m;set w6547m;format value best32.;run;
proc export data=w6547m outfile="%sysfunc(pathname(work))/W6547.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6547;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6547:;quit;
