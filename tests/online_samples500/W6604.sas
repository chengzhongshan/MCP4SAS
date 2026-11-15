/* New workflow W6604; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6604i;
ne=28;nc=29;me=2.5;mc=0.5;se=1.2;sc=1.4333333333333333;output;
run;
%n26_compeff(w6604i,w6604o);run;
data w6604m(keep=metric value);set w6604o;length metric $120;array measured[*] estimate lower upper;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6604m;set w6604m;format value best32.;run;
proc export data=w6604m outfile="%sysfunc(pathname(work))/W6604.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6604;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6604:;quit;
