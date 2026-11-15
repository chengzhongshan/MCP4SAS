/* New workflow W6554; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6554i;
n11=41;n12=63;n21=17;n22=49;output;
n11=36;n12=64;n21=14;n22=50;output;
n11=29;n12=66;n21=28;n22=57;output;
run;
%n26_compodds(w6554i,w6554o);run;
%n26_wavgodds(w6554o,w6554pool,1,0.95);run;
data w6554m(keep=metric value);set w6554pool;length metric $120;array measured[*] estimate lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6554m;set w6554m;format value best32.;run;
proc export data=w6554m outfile="%sysfunc(pathname(work))/W6554.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6554;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6554:;quit;
