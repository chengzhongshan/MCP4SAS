/* New workflow W6803; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6803i;
length gene $80;
gene='p01';raw_p=1e-05;output;
gene='p02';raw_p=0.2529212002745319;output;
gene='p03';raw_p=0.1541123895624955;output;
gene='p04';raw_p=0;output;
gene='p05';raw_p=0.20404285084270635;output;
gene='p06';raw_p=0.6793186037732412;output;
gene='p07';raw_p=0.001;output;
gene='p08';raw_p=0.8176794838340518;output;
gene='p09';raw_p=0.33462049012850126;output;
run;
proc multtest inpvalues=w6803i hoc out=w6803o noprint;run;
data w6803m(keep=metric value);set w6803o;length metric $120;array measured[*] hoc_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6803m;set w6803m;format value best32.;run;
proc export data=w6803m outfile="%sysfunc(pathname(work))/W6803.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6803;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6803:;quit;
