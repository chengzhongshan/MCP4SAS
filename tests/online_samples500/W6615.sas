/* New workflow W6615; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6615i;
ne=50;nc=40;me=3.875;mc=0.5;se=1.75;sc=1.8;output;
run;
%n26_compeff(w6615i,w6615o);run;
data w6615m(keep=metric value);set w6615o;length metric $120;array measured[*] estimate lower upper;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6615m;set w6615m;format value best32.;run;
proc export data=w6615m outfile="%sysfunc(pathname(work))/W6615.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6615;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6615:;quit;
