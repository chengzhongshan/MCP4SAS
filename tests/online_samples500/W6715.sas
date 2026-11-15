/* New workflow W6715; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6715i;
length gene $80;
gene='p01';raw_p=0.05;output;
gene='p02';raw_p=0.13681603758802674;output;
gene='p03';raw_p=0.7235740917261321;output;
gene='p04';raw_p=0;output;
gene='p05';raw_p=0.8051328737014839;output;
gene='p06';raw_p=0.5281867285376842;output;
gene='p07';raw_p=1e-05;output;
run;
data w6715o;set w6715i;bon_p=min(1,7*raw_p);sid_p=1-(1-raw_p)**7;run;
data w6715m(keep=metric value);set w6715o;length metric $120;array measured[*] bon_p sid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6715m;set w6715m;format value best32.;run;
proc export data=w6715m outfile="%sysfunc(pathname(work))/W6715.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6715;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6715:;quit;
