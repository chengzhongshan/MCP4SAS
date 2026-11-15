/* New workflow W6618; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6618i;
ne=56;nc=43;me=4.25;mc=0.5;se=1.9;sc=1.9;output;
run;
%n26_compeff(w6618i,w6618o);run;
data w6618m(keep=metric value);set w6618o;length metric $120;array measured[*] estimate lower upper;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6618m;set w6618m;format value best32.;run;
proc export data=w6618m outfile="%sysfunc(pathname(work))/W6618.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6618;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6618:;quit;
