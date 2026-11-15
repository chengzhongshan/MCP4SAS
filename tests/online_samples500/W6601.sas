/* New workflow W6601; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6601i;
ne=22;nc=26;me=2.125;mc=0.5;se=1.05;sc=1.3333333333333335;output;
run;
%n26_compeff(w6601i,w6601o);run;
data w6601m(keep=metric value);set w6601o;length metric $120;array measured[*] estimate lower upper;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6601m;set w6601m;format value best32.;run;
proc export data=w6601m outfile="%sysfunc(pathname(work))/W6601.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6601;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6601:;quit;
