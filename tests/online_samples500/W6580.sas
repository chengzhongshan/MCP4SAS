/* New workflow W6580; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6580i;
n11=0;n12=37;n21=37;n22=54;output;
n11=27;n12=22;n21=14;n22=47;output;
n11=21;n12=53;n21=37;n22=26;output;
n11=26;n12=58;n21=17;n22=91;output;
n11=45;n12=31;n21=29;n22=77;output;
n11=25;n12=27;n21=26;n22=31;output;
n11=45;n12=85;n21=27;n22=48;output;
n11=44;n12=40;n21=7;n22=30;output;
n11=42;n12=53;n21=17;n22=81;output;
run;
%n26_compodds(w6580i,w6580o);run;
%n26_wavgodds(w6580o,w6580pool,3,0.8);run;
data w6580m(keep=metric value);set w6580pool;length metric $120;array measured[*] estimate lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6580m;set w6580m;format value best32.;run;
proc export data=w6580m outfile="%sysfunc(pathname(work))/W6580.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6580;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6580:;quit;
