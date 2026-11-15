/* New workflow W6614; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6614i;
ne=48;nc=39;me=3.75;mc=0.5;se=1.7;sc=1.7666666666666666;output;
run;
%n26_compeff(w6614i,w6614o);run;
data w6614m(keep=metric value);set w6614o;length metric $120;array measured[*] estimate lower upper;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6614m;set w6614m;format value best32.;run;
proc export data=w6614m outfile="%sysfunc(pathname(work))/W6614.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6614;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6614:;quit;
