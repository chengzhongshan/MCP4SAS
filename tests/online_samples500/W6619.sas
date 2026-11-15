/* New workflow W6619; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6619i;
ne=58;nc=44;me=4.375;mc=0.5;se=1.95;sc=1.9333333333333333;output;
run;
%n26_compeff(w6619i,w6619o);run;
data w6619m(keep=metric value);set w6619o;length metric $120;array measured[*] estimate lower upper;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6619m;set w6619m;format value best32.;run;
proc export data=w6619m outfile="%sysfunc(pathname(work))/W6619.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6619;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6619:;quit;
