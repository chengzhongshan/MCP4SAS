/* New workflow W6564; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6564i;
n11=0;n12=33;n21=15;n22=47;output;
n11=31;n12=26;n21=25;n22=84;output;
n11=42;n12=43;n21=23;n22=26;output;
n11=17;n12=78;n21=19;n22=80;output;
n11=27;n12=54;n21=20;n22=50;output;
n11=14;n12=25;n21=19;n22=82;output;
n11=22;n12=87;n21=28;n22=44;output;
run;
%n26_compodds(w6564i,w6564o);run;
%n26_wavgodds(w6564o,w6564pool,3,0.8);run;
data w6564m(keep=metric value);set w6564pool;length metric $120;array measured[*] estimate lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6564m;set w6564m;format value best32.;run;
proc export data=w6564m outfile="%sysfunc(pathname(work))/W6564.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6564;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6564:;quit;
