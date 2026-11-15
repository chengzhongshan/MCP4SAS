/* New workflow W6722; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6722i;
length gene $80;
gene='p01';raw_p=0.2;output;
gene='p02';raw_p=0.5588689237468246;output;
gene='p03';raw_p=0.9811062177621659;output;
gene='p04';raw_p=1e-05;output;
gene='p05';raw_p=0.7858171560782636;output;
gene='p06';raw_p=0.5418229158577673;output;
gene='p07';raw_p=0.001;output;
gene='p08';raw_p=0.7627430313163847;output;
run;
proc multtest inpvalues=w6722i bon out=w6722o noprint;run;
data w6722m(keep=metric value);set w6722o;length metric $120;array measured[*] bon_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6722m;set w6722m;format value best32.;run;
proc export data=w6722m outfile="%sysfunc(pathname(work))/W6722.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6722;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6722:;quit;
