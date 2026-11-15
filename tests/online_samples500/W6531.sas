/* New workflow W6531; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6531i;
n11=0;n12=68;n21=32;n22=76;output;
run;
%n26_compodds(w6531i,w6531o);run;
data w6531m(keep=metric value);set w6531o;length metric $120;array measured[*] estimate lower upper variance;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6531m;set w6531m;format value best32.;run;
proc export data=w6531m outfile="%sysfunc(pathname(work))/W6531.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6531;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6531:;quit;
