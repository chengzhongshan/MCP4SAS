/* New workflow W6705; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6705i;
length gene $80;
gene='p01';raw_p=0;output;
gene='p02';raw_p=0.4131756217816327;output;
gene='p03';raw_p=0.9670858168183973;output;
gene='p04';raw_p=1;output;
gene='p05';raw_p=0.6982400851044728;output;
gene='p06';raw_p=0.9948406374120334;output;
gene='p07';raw_p=0.01;output;
gene='p08';raw_p=0.20575894935088124;output;
gene='p09';raw_p=0.3493158475191369;output;
gene='p10';raw_p=0.01;output;
gene='p11';raw_p=0.864476847573435;output;
run;
data w6705o;set w6705i;bon_p=min(1,11*raw_p);sid_p=1-(1-raw_p)**11;run;
data w6705m(keep=metric value);set w6705o;length metric $120;array measured[*] bon_p sid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6705m;set w6705m;format value best32.;run;
proc export data=w6705m outfile="%sysfunc(pathname(work))/W6705.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6705;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6705:;quit;
