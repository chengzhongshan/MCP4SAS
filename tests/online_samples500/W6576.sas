/* New workflow W6576; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6576i;
n11=0;n12=86;n21=15;n22=29;output;
n11=45;n12=76;n21=27;n22=25;output;
n11=13;n12=52;n21=11;n22=28;output;
n11=24;n12=71;n21=13;n22=51;output;
n11=24;n12=53;n21=29;n22=55;output;
run;
%n26_compodds(w6576i,w6576o);run;
%n26_wavgodds(w6576o,w6576pool,3,0.8);run;
data w6576m(keep=metric value);set w6576pool;length metric $120;array measured[*] estimate lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6576m;set w6576m;format value best32.;run;
proc export data=w6576m outfile="%sysfunc(pathname(work))/W6576.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6576;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6576:;quit;
