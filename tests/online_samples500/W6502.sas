/* New workflow W6502; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6502i;
n11=20;n12=78;n21=19;n22=48;output;
run;
%n26_compodds(w6502i,w6502o);run;
data w6502m(keep=metric value);set w6502o;length metric $120;array measured[*] estimate lower upper variance;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6502m;set w6502m;format value best32.;run;
proc export data=w6502m outfile="%sysfunc(pathname(work))/W6502.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6502;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6502:;quit;
