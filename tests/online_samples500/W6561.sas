/* New workflow W6561; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6561i;
n11=0;n12=44;n21=11;n22=72;output;
n11=19;n12=56;n21=28;n22=29;output;
n11=28;n12=70;n21=33;n22=88;output;
n11=34;n12=25;n21=18;n22=82;output;
run;
%n26_compodds(w6561i,w6561o);run;
%n26_wavgodds(w6561o,w6561pool,3,0.9);run;
data w6561m(keep=metric value);set w6561pool;length metric $120;array measured[*] estimate lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6561m;set w6561m;format value best32.;run;
proc export data=w6561m outfile="%sysfunc(pathname(work))/W6561.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6561;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6561:;quit;
