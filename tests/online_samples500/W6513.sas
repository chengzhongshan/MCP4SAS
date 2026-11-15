/* New workflow W6513; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6513i;
n11=9;n12=31;n21=36;n22=45;output;
run;
%n26_compodds(w6513i,w6513o);run;
data w6513m(keep=metric value);set w6513o;length metric $120;array measured[*] estimate lower upper variance;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6513m;set w6513m;format value best32.;run;
proc export data=w6513m outfile="%sysfunc(pathname(work))/W6513.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6513;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6513:;quit;
