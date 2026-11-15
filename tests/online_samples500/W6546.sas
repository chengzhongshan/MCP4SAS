/* New workflow W6546; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6546i;
n11=19;n12=38;n21=12;n22=41;output;
n11=28;n12=88;n21=27;n22=80;output;
n11=45;n12=57;n21=11;n22=35;output;
n11=36;n12=24;n21=24;n22=55;output;
n11=29;n12=32;n21=13;n22=28;output;
n11=11;n12=87;n21=28;n22=55;output;
n11=42;n12=63;n21=29;n22=68;output;
n11=8;n12=38;n21=36;n22=76;output;
n11=33;n12=88;n21=36;n22=80;output;
run;
%n26_compodds(w6546i,w6546o);run;
%n26_wavgodds(w6546o,w6546pool,1,0.95);run;
data w6546m(keep=metric value);set w6546pool;length metric $120;array measured[*] estimate lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6546m;set w6546m;format value best32.;run;
proc export data=w6546m outfile="%sysfunc(pathname(work))/W6546.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6546;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6546:;quit;
