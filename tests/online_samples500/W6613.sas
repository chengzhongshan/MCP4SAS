/* New workflow W6613; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6613i;
ne=46;nc=38;me=3.625;mc=0.5;se=1.65;sc=1.7333333333333334;output;
run;
%n26_compeff(w6613i,w6613o);run;
data w6613m(keep=metric value);set w6613o;length metric $120;array measured[*] estimate lower upper;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6613m;set w6613m;format value best32.;run;
proc export data=w6613m outfile="%sysfunc(pathname(work))/W6613.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6613;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6613:;quit;
