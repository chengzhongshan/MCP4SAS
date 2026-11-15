/* New workflow W6542; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6542i;
n11=39;n12=68;n21=28;n22=34;output;
n11=13;n12=43;n21=17;n22=57;output;
n11=27;n12=44;n21=14;n22=93;output;
n11=30;n12=25;n21=9;n22=33;output;
n11=31;n12=48;n21=12;n22=25;output;
run;
%n26_compodds(w6542i,w6542o);run;
%n26_wavgodds(w6542o,w6542pool,1,0.95);run;
data w6542m(keep=metric value);set w6542pool;length metric $120;array measured[*] estimate lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6542m;set w6542m;format value best32.;run;
proc export data=w6542m outfile="%sysfunc(pathname(work))/W6542.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6542;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6542:;quit;
