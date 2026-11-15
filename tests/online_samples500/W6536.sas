/* New workflow W6536; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6536i;
n11=0;n12=78;n21=31;n22=29;output;
run;
%n26_compodds(w6536i,w6536o);run;
data w6536m(keep=metric value);set w6536o;length metric $120;array measured[*] estimate lower upper variance;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6536m;set w6536m;format value best32.;run;
proc export data=w6536m outfile="%sysfunc(pathname(work))/W6536.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6536;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6536:;quit;
