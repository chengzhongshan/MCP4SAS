/* New workflow W6516; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6516i;
n11=28;n12=84;n21=17;n22=31;output;
run;
%n26_compodds(w6516i,w6516o);run;
data w6516m(keep=metric value);set w6516o;length metric $120;array measured[*] estimate lower upper variance;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6516m;set w6516m;format value best32.;run;
proc export data=w6516m outfile="%sysfunc(pathname(work))/W6516.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6516;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6516:;quit;
