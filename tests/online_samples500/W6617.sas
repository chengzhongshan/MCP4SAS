/* New workflow W6617; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6617i;
ne=54;nc=42;me=4.125;mc=0.5;se=1.85;sc=1.8666666666666667;output;
run;
%n26_compeff(w6617i,w6617o);run;
data w6617m(keep=metric value);set w6617o;length metric $120;array measured[*] estimate lower upper;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6617m;set w6617m;format value best32.;run;
proc export data=w6617m outfile="%sysfunc(pathname(work))/W6617.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6617;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6617:;quit;
