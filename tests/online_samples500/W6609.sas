/* New workflow W6609; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6609i;
ne=38;nc=34;me=3.125;mc=0.5;se=1.45;sc=1.6;output;
run;
%n26_compeff(w6609i,w6609o);run;
data w6609m(keep=metric value);set w6609o;length metric $120;array measured[*] estimate lower upper;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6609m;set w6609m;format value best32.;run;
proc export data=w6609m outfile="%sysfunc(pathname(work))/W6609.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6609;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6609:;quit;
