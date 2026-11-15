/* New workflow W6608; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6608i;
ne=36;nc=33;me=3.0;mc=0.5;se=1.4;sc=1.5666666666666667;output;
run;
%n26_compeff(w6608i,w6608o);run;
data w6608m(keep=metric value);set w6608o;length metric $120;array measured[*] estimate lower upper;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6608m;set w6608m;format value best32.;run;
proc export data=w6608m outfile="%sysfunc(pathname(work))/W6608.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6608;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6608:;quit;
