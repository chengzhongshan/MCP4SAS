/* New workflow W6566; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6566i;
n11=0;n12=26;n21=24;n22=50;output;
n11=30;n12=23;n21=39;n22=95;output;
n11=44;n12=68;n21=10;n22=84;output;
n11=17;n12=39;n21=15;n22=50;output;
n11=21;n12=67;n21=26;n22=80;output;
n11=41;n12=77;n21=29;n22=71;output;
n11=11;n12=28;n21=8;n22=63;output;
n11=21;n12=34;n21=7;n22=93;output;
n11=34;n12=31;n21=21;n22=40;output;
run;
%n26_compodds(w6566i,w6566o);run;
%n26_wavgodds(w6566o,w6566pool,3,0.95);run;
data w6566m(keep=metric value);set w6566pool;length metric $120;array measured[*] estimate lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6566m;set w6566m;format value best32.;run;
proc export data=w6566m outfile="%sysfunc(pathname(work))/W6566.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6566;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6566:;quit;
