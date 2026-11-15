/* New workflow W6693; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6693i;
n11=12;n12=64;n21=16;n22=42;output;
n11=40;n12=39;n21=10;n22=30;output;
n11=26;n12=36;n21=18;n22=60;output;
n11=23;n12=23;n21=11;n22=31;output;
n11=22;n12=20;n21=17;n22=49;output;
n11=29;n12=48;n21=5;n22=78;output;
n11=32;n12=29;n21=22;n22=37;output;
n11=29;n12=58;n21=18;n22=54;output;
n11=12;n12=54;n21=14;n22=68;output;
run;
%n26_mhodds(w6693i,w6693o,0.9);run;
data w6693m(keep=metric value);set w6693o;length metric $120;array measured[*] estimate;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6693m;set w6693m;format value best32.;run;
proc export data=w6693m outfile="%sysfunc(pathname(work))/W6693.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6693;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6693:;quit;
