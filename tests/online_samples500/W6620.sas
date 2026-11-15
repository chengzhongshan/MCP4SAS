/* New workflow W6620; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6620i;
ne=60;nc=45;me=4.5;mc=0.5;se=2.0;sc=1.9666666666666668;output;
run;
%n26_compeff(w6620i,w6620o);run;
data w6620m(keep=metric value);set w6620o;length metric $120;array measured[*] estimate lower upper;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6620m;set w6620m;format value best32.;run;
proc export data=w6620m outfile="%sysfunc(pathname(work))/W6620.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6620;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6620:;quit;
