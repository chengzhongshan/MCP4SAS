/* New workflow W6551; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6551i;
n11=39;n12=67;n21=11;n22=61;output;
n11=35;n12=28;n21=17;n22=60;output;
n11=11;n12=30;n21=39;n22=43;output;
n11=15;n12=65;n21=31;n22=66;output;
n11=9;n12=20;n21=13;n22=75;output;
n11=26;n12=76;n21=23;n22=73;output;
n11=13;n12=86;n21=23;n22=47;output;
run;
%n26_compodds(w6551i,w6551o);run;
%n26_wavgodds(w6551o,w6551pool,1,0.95);run;
data w6551m(keep=metric value);set w6551pool;length metric $120;array measured[*] estimate lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6551m;set w6551m;format value best32.;run;
proc export data=w6551m outfile="%sysfunc(pathname(work))/W6551.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6551;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6551:;quit;
