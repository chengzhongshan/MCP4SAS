/* New workflow W6688; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6688i;
n11=11;n12=41;n21=6;n22=51;output;
n11=32;n12=40;n21=5;n22=70;output;
n11=25;n12=54;n21=19;n22=35;output;
n11=9;n12=54;n21=21;n22=43;output;
run;
%n26_mhodds(w6688i,w6688o,0.8);run;
data w6688m(keep=metric value);set w6688o;length metric $120;array measured[*] estimate;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6688m;set w6688m;format value best32.;run;
proc export data=w6688m outfile="%sysfunc(pathname(work))/W6688.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6688;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6688:;quit;
