/* New workflow W6696; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6696i;
n11=36;n12=48;n21=29;n22=77;output;
n11=29;n12=21;n21=27;n22=62;output;
n11=11;n12=63;n21=16;n22=69;output;
n11=18;n12=41;n21=20;n22=80;output;
n11=30;n12=29;n21=16;n22=71;output;
run;
%n26_mhodds(w6696i,w6696o,0.8);run;
data w6696m(keep=metric value);set w6696o;length metric $120;array measured[*] estimate;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6696m;set w6696m;format value best32.;run;
proc export data=w6696m outfile="%sysfunc(pathname(work))/W6696.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6696;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6696:;quit;
