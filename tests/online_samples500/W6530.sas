/* New workflow W6530; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6530i;
n11=0;n12=33;n21=19;n22=49;output;
run;
%n26_compodds(w6530i,w6530o);run;
data w6530m(keep=metric value);set w6530o;length metric $120;array measured[*] estimate lower upper variance;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6530m;set w6530m;format value best32.;run;
proc export data=w6530m outfile="%sysfunc(pathname(work))/W6530.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6530;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6530:;quit;
