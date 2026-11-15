/* New workflow W6565; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6565i;
n11=0;n12=33;n21=24;n22=76;output;
n11=21;n12=54;n21=36;n22=42;output;
n11=15;n12=59;n21=29;n22=67;output;
n11=18;n12=41;n21=34;n22=74;output;
n11=21;n12=33;n21=24;n22=40;output;
n11=13;n12=82;n21=35;n22=34;output;
n11=24;n12=66;n21=9;n22=58;output;
n11=20;n12=58;n21=39;n22=26;output;
run;
%n26_compodds(w6565i,w6565o);run;
%n26_wavgodds(w6565o,w6565pool,3,0.9);run;
data w6565m(keep=metric value);set w6565pool;length metric $120;array measured[*] estimate lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6565m;set w6565m;format value best32.;run;
proc export data=w6565m outfile="%sysfunc(pathname(work))/W6565.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6565;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6565:;quit;
