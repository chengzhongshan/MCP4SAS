/* New workflow W6523; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6523i;
n11=0;n12=22;n21=7;n22=29;output;
run;
%n26_compodds(w6523i,w6523o);run;
data w6523m(keep=metric value);set w6523o;length metric $120;array measured[*] estimate lower upper variance;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6523m;set w6523m;format value best32.;run;
proc export data=w6523m outfile="%sysfunc(pathname(work))/W6523.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6523;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6523:;quit;
