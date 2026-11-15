/* New workflow W6831; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6831i;
length gene $80;
gene='p01';raw_p=1;output;
gene='p02';raw_p=0.835381559862494;output;
gene='p03';raw_p=0.79775598522802;output;
gene='p04';raw_p=1e-05;output;
gene='p05';raw_p=0.8627339365872481;output;
gene='p06';raw_p=0.6155839786528355;output;
gene='p07';raw_p=0.005;output;
gene='p08';raw_p=0.641819881405599;output;
gene='p09';raw_p=0.8445394701311927;output;
gene='p10';raw_p=0.8;output;
run;
proc multtest inpvalues=w6831i fdr out=w6831o noprint;run;
data w6831m(keep=metric value);set w6831o;length metric $120;array measured[*] fdr_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6831m;set w6831m;format value best32.;run;
proc export data=w6831m outfile="%sysfunc(pathname(work))/W6831.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6831;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6831:;quit;
