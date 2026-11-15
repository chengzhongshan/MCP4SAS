/* New workflow W6605; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6605i;
ne=30;nc=30;me=2.625;mc=0.5;se=1.25;sc=1.4666666666666668;output;
run;
%n26_compeff(w6605i,w6605o);run;
data w6605m(keep=metric value);set w6605o;length metric $120;array measured[*] estimate lower upper;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6605m;set w6605m;format value best32.;run;
proc export data=w6605m outfile="%sysfunc(pathname(work))/W6605.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6605;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6605:;quit;
