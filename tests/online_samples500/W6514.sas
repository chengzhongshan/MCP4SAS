/* New workflow W6514; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6514i;
n11=41;n12=39;n21=9;n22=58;output;
run;
%n26_compodds(w6514i,w6514o);run;
data w6514m(keep=metric value);set w6514o;length metric $120;array measured[*] estimate lower upper variance;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6514m;set w6514m;format value best32.;run;
proc export data=w6514m outfile="%sysfunc(pathname(work))/W6514.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6514;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6514:;quit;
