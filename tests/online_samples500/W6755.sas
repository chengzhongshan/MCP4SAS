/* New workflow W6755; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6755i;
length gene $80;
gene='p01';raw_p=0.005;output;
gene='p02';raw_p=0.9646525108844755;output;
gene='p03';raw_p=0.7716790867092714;output;
gene='p04';raw_p=0.2;output;
gene='p05';raw_p=0.22337615655513232;output;
gene='p06';raw_p=0.8820739801077575;output;
gene='p07';raw_p=0.2;output;
run;
proc multtest inpvalues=w6755i sid out=w6755o noprint;run;
data w6755m(keep=metric value);set w6755o;length metric $120;array measured[*] sid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6755m;set w6755m;format value best32.;run;
proc export data=w6755m outfile="%sysfunc(pathname(work))/W6755.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6755;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6755:;quit;
