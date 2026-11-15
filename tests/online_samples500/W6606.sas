/* New workflow W6606; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6606i;
ne=32;nc=31;me=2.75;mc=0.5;se=1.3;sc=1.5;output;
run;
%n26_compeff(w6606i,w6606o);run;
data w6606m(keep=metric value);set w6606o;length metric $120;array measured[*] estimate lower upper;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6606m;set w6606m;format value best32.;run;
proc export data=w6606m outfile="%sysfunc(pathname(work))/W6606.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6606;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6606:;quit;
