/* New workflow W6538; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6538i;
n11=0;n12=48;n21=7;n22=86;output;
run;
%n26_compodds(w6538i,w6538o);run;
data w6538m(keep=metric value);set w6538o;length metric $120;array measured[*] estimate lower upper variance;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6538m;set w6538m;format value best32.;run;
proc export data=w6538m outfile="%sysfunc(pathname(work))/W6538.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6538;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6538:;quit;
