/* New workflow W6563; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6563i;
n11=0;n12=86;n21=10;n22=49;output;
n11=22;n12=65;n21=21;n22=69;output;
n11=17;n12=67;n21=35;n22=54;output;
n11=44;n12=85;n21=24;n22=31;output;
n11=8;n12=84;n21=24;n22=93;output;
n11=34;n12=79;n21=11;n22=41;output;
run;
%n26_compodds(w6563i,w6563o);run;
%n26_wavgodds(w6563o,w6563pool,3,0.99);run;
data w6563m(keep=metric value);set w6563pool;length metric $120;array measured[*] estimate lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6563m;set w6563m;format value best32.;run;
proc export data=w6563m outfile="%sysfunc(pathname(work))/W6563.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6563;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6563:;quit;
