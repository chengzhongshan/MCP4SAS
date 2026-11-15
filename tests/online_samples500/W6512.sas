/* New workflow W6512; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6512i;
n11=30;n12=48;n21=26;n22=34;output;
run;
%n26_compodds(w6512i,w6512o);run;
data w6512m(keep=metric value);set w6512o;length metric $120;array measured[*] estimate lower upper variance;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6512m;set w6512m;format value best32.;run;
proc export data=w6512m outfile="%sysfunc(pathname(work))/W6512.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6512;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6512:;quit;
