/* New workflow W6520; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6520i;
n11=26;n12=73;n21=29;n22=39;output;
run;
%n26_compodds(w6520i,w6520o);run;
data w6520m(keep=metric value);set w6520o;length metric $120;array measured[*] estimate lower upper variance;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6520m;set w6520m;format value best32.;run;
proc export data=w6520m outfile="%sysfunc(pathname(work))/W6520.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6520;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6520:;quit;
