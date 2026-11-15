/* New workflow W6545; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6545i;
n11=34;n12=48;n21=28;n22=36;output;
n11=45;n12=60;n21=10;n22=81;output;
n11=9;n12=55;n21=19;n22=58;output;
n11=44;n12=34;n21=23;n22=85;output;
n11=36;n12=46;n21=7;n22=84;output;
n11=12;n12=67;n21=7;n22=31;output;
n11=40;n12=83;n21=24;n22=55;output;
n11=23;n12=31;n21=39;n22=69;output;
run;
%n26_compodds(w6545i,w6545o);run;
%n26_wavgodds(w6545o,w6545pool,1,0.95);run;
data w6545m(keep=metric value);set w6545pool;length metric $120;array measured[*] estimate lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6545m;set w6545m;format value best32.;run;
proc export data=w6545m outfile="%sysfunc(pathname(work))/W6545.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6545;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6545:;quit;
