/* New workflow W6683; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6683i;
n11=15;n12=26;n21=23;n22=49;output;
n11=10;n12=20;n21=30;n22=58;output;
n11=34;n12=21;n21=20;n22=46;output;
n11=32;n12=55;n21=6;n22=39;output;
n11=18;n12=48;n21=24;n22=76;output;
n11=12;n12=36;n21=24;n22=68;output;
run;
%n26_mhodds(w6683i,w6683o,0.99);run;
data w6683m(keep=metric value);set w6683o;length metric $120;array measured[*] estimate;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6683m;set w6683m;format value best32.;run;
proc export data=w6683m outfile="%sysfunc(pathname(work))/W6683.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6683;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6683:;quit;
