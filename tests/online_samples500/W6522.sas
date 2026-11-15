/* New workflow W6522; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6522i;
n11=0;n12=83;n21=13;n22=58;output;
run;
%n26_compodds(w6522i,w6522o);run;
data w6522m(keep=metric value);set w6522o;length metric $120;array measured[*] estimate lower upper variance;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6522m;set w6522m;format value best32.;run;
proc export data=w6522m outfile="%sysfunc(pathname(work))/W6522.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6522;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6522:;quit;
