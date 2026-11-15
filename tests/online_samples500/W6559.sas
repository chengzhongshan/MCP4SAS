/* New workflow W6559; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6559i;
n11=31;n12=41;n21=36;n22=49;output;
n11=27;n12=57;n21=8;n22=37;output;
n11=25;n12=40;n21=11;n22=69;output;
n11=24;n12=61;n21=23;n22=80;output;
n11=30;n12=52;n21=24;n22=29;output;
n11=12;n12=23;n21=8;n22=27;output;
n11=32;n12=70;n21=16;n22=67;output;
n11=29;n12=83;n21=27;n22=27;output;
run;
%n26_compodds(w6559i,w6559o);run;
%n26_wavgodds(w6559o,w6559pool,1,0.95);run;
data w6559m(keep=metric value);set w6559pool;length metric $120;array measured[*] estimate lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6559m;set w6559m;format value best32.;run;
proc export data=w6559m outfile="%sysfunc(pathname(work))/W6559.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6559;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6559:;quit;
