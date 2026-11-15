/* New workflow W6518; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6518i;
n11=12;n12=53;n21=16;n22=91;output;
run;
%n26_compodds(w6518i,w6518o);run;
data w6518m(keep=metric value);set w6518o;length metric $120;array measured[*] estimate lower upper variance;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6518m;set w6518m;format value best32.;run;
proc export data=w6518m outfile="%sysfunc(pathname(work))/W6518.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6518;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6518:;quit;
