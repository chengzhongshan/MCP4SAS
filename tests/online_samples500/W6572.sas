/* New workflow W6572; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6572i;
n11=0;n12=20;n21=33;n22=87;output;
n11=44;n12=59;n21=26;n22=54;output;
n11=11;n12=71;n21=20;n22=92;output;
n11=16;n12=57;n21=17;n22=48;output;
n11=10;n12=34;n21=23;n22=77;output;
n11=18;n12=62;n21=35;n22=91;output;
n11=28;n12=50;n21=37;n22=77;output;
n11=41;n12=63;n21=11;n22=54;output;
run;
%n26_compodds(w6572i,w6572o);run;
%n26_wavgodds(w6572o,w6572pool,3,0.8);run;
data w6572m(keep=metric value);set w6572pool;length metric $120;array measured[*] estimate lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6572m;set w6572m;format value best32.;run;
proc export data=w6572m outfile="%sysfunc(pathname(work))/W6572.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6572;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6572:;quit;
