/* New workflow W6870; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6870i;
length gene $80;
gene='p01';raw_p=0.001;output;
gene='p02';raw_p=0.9685905850076142;output;
gene='p03';raw_p=0.882013729917222;output;
gene='p04';raw_p=0.005;output;
gene='p05';raw_p=0.2889422984084784;output;
gene='p06';raw_p=0.21558804965417855;output;
gene='p07';raw_p=1;output;
gene='p08';raw_p=0.24129250001399516;output;
gene='p09';raw_p=0.6368210402182882;output;
run;
data w6870o;set w6870i;retain adjusted 0;adjusted=max(adjusted,raw_p);run;
data w6870m(keep=metric value);set w6870o;length metric $120;array measured[*] adjusted;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6870m;set w6870m;format value best32.;run;
proc export data=w6870m outfile="%sysfunc(pathname(work))/W6870.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6870;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6870:;quit;
