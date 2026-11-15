/* New workflow W6521; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6521i;
n11=0;n12=26;n21=22;n22=70;output;
run;
%n26_compodds(w6521i,w6521o);run;
data w6521m(keep=metric value);set w6521o;length metric $120;array measured[*] estimate lower upper variance;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6521m;set w6521m;format value best32.;run;
proc export data=w6521m outfile="%sysfunc(pathname(work))/W6521.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6521;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6521:;quit;
