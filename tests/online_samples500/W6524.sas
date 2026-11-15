/* New workflow W6524; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6524i;
n11=0;n12=84;n21=14;n22=49;output;
run;
%n26_compodds(w6524i,w6524o);run;
data w6524m(keep=metric value);set w6524o;length metric $120;array measured[*] estimate lower upper variance;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6524m;set w6524m;format value best32.;run;
proc export data=w6524m outfile="%sysfunc(pathname(work))/W6524.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6524;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6524:;quit;
