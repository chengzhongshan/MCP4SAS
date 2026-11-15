/* New workflow W6526; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6526i;
n11=0;n12=20;n21=8;n22=48;output;
run;
%n26_compodds(w6526i,w6526o);run;
data w6526m(keep=metric value);set w6526o;length metric $120;array measured[*] estimate lower upper variance;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6526m;set w6526m;format value best32.;run;
proc export data=w6526m outfile="%sysfunc(pathname(work))/W6526.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6526;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6526:;quit;
