/* New workflow W6603; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6603i;
ne=26;nc=28;me=2.375;mc=0.5;se=1.15;sc=1.4000000000000001;output;
run;
%n26_compeff(w6603i,w6603o);run;
data w6603m(keep=metric value);set w6603o;length metric $120;array measured[*] estimate lower upper;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6603m;set w6603m;format value best32.;run;
proc export data=w6603m outfile="%sysfunc(pathname(work))/W6603.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6603;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6603:;quit;
