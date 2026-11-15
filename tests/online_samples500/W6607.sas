/* New workflow W6607; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6607i;
ne=34;nc=32;me=2.875;mc=0.5;se=1.35;sc=1.5333333333333334;output;
run;
%n26_compeff(w6607i,w6607o);run;
data w6607m(keep=metric value);set w6607o;length metric $120;array measured[*] estimate lower upper;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6607m;set w6607m;format value best32.;run;
proc export data=w6607m outfile="%sysfunc(pathname(work))/W6607.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6607;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6607:;quit;
