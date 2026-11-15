/* New workflow W6725; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6725i;
length gene $80;
gene='p01';raw_p=0.05;output;
gene='p02';raw_p=0.5457881921681473;output;
gene='p03';raw_p=0.29904712830185354;output;
gene='p04';raw_p=0.8;output;
gene='p05';raw_p=0.7030273171338906;output;
gene='p06';raw_p=0.5667258168775865;output;
gene='p07';raw_p=0.05;output;
gene='p08';raw_p=0.3120926117366697;output;
gene='p09';raw_p=0.022192930907385278;output;
gene='p10';raw_p=0.001;output;
gene='p11';raw_p=0.4939935461639826;output;
run;
proc multtest inpvalues=w6725i bon out=w6725o noprint;run;
data w6725m(keep=metric value);set w6725o;length metric $120;array measured[*] bon_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6725m;set w6725m;format value best32.;run;
proc export data=w6725m outfile="%sysfunc(pathname(work))/W6725.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6725;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6725:;quit;
