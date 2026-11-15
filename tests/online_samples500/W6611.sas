/* New workflow W6611; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6611i;
ne=42;nc=36;me=3.375;mc=0.5;se=1.55;sc=1.6666666666666667;output;
run;
%n26_compeff(w6611i,w6611o);run;
data w6611m(keep=metric value);set w6611o;length metric $120;array measured[*] estimate lower upper;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6611m;set w6611m;format value best32.;run;
proc export data=w6611m outfile="%sysfunc(pathname(work))/W6611.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6611;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6611:;quit;
