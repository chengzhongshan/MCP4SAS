/* New workflow W6610; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6610i;
ne=40;nc=35;me=3.25;mc=0.5;se=1.5;sc=1.6333333333333333;output;
run;
%n26_compeff(w6610i,w6610o);run;
data w6610m(keep=metric value);set w6610o;length metric $120;array measured[*] estimate lower upper;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6610m;set w6610m;format value best32.;run;
proc export data=w6610m outfile="%sysfunc(pathname(work))/W6610.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6610;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6610:;quit;
