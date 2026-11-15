/* New workflow W6579; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6579i;
n11=0;n12=31;n21=36;n22=28;output;
n11=33;n12=50;n21=28;n22=62;output;
n11=9;n12=88;n21=8;n22=89;output;
n11=22;n12=22;n21=14;n22=34;output;
n11=23;n12=54;n21=35;n22=67;output;
n11=44;n12=21;n21=28;n22=29;output;
n11=9;n12=29;n21=29;n22=81;output;
n11=29;n12=62;n21=40;n22=70;output;
run;
%n26_compodds(w6579i,w6579o);run;
%n26_wavgodds(w6579o,w6579pool,3,0.99);run;
data w6579m(keep=metric value);set w6579pool;length metric $120;array measured[*] estimate lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6579m;set w6579m;format value best32.;run;
proc export data=w6579m outfile="%sysfunc(pathname(work))/W6579.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6579;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6579:;quit;
