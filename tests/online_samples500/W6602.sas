/* New workflow W6602; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6602i;
ne=24;nc=27;me=2.25;mc=0.5;se=1.1;sc=1.3666666666666667;output;
run;
%n26_compeff(w6602i,w6602o);run;
data w6602m(keep=metric value);set w6602o;length metric $120;array measured[*] estimate lower upper;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6602m;set w6602m;format value best32.;run;
proc export data=w6602m outfile="%sysfunc(pathname(work))/W6602.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6602;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6602:;quit;
