/* New workflow W6682; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6682i;
n11=36;n12=46;n21=12;n22=66;output;
n11=16;n12=41;n21=27;n22=47;output;
n11=22;n12=47;n21=18;n22=51;output;
n11=32;n12=61;n21=14;n22=34;output;
n11=38;n12=45;n21=19;n22=76;output;
run;
%n26_mhodds(w6682i,w6682o,0.95);run;
data w6682m(keep=metric value);set w6682o;length metric $120;array measured[*] estimate;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6682m;set w6682m;format value best32.;run;
proc export data=w6682m outfile="%sysfunc(pathname(work))/W6682.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6682;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6682:;quit;
