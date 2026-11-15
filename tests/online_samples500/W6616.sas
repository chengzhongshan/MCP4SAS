/* New workflow W6616; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6616i;
ne=52;nc=41;me=4.0;mc=0.5;se=1.8;sc=1.8333333333333335;output;
run;
%n26_compeff(w6616i,w6616o);run;
data w6616m(keep=metric value);set w6616o;length metric $120;array measured[*] estimate lower upper;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6616m;set w6616m;format value best32.;run;
proc export data=w6616m outfile="%sysfunc(pathname(work))/W6616.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6616;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6616:;quit;
