/* New workflow W6852; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6852i;
length gene $80;
gene='p01';raw_p=0.05;output;
gene='p02';raw_p=0.8633902734405264;output;
gene='p03';raw_p=0.19391802488365772;output;
gene='p04';raw_p=0.8;output;
gene='p05';raw_p=0.8787020082528358;output;
gene='p06';raw_p=0.893923056015357;output;
gene='p07';raw_p=0.05;output;
gene='p08';raw_p=0.9682531086254343;output;
gene='p09';raw_p=0.35414309473995254;output;
gene='p10';raw_p=0.005;output;
gene='p11';raw_p=0.6717349315439374;output;
run;
proc multtest inpvalues=w6852i dependentfdr out=w6852o noprint;run;
data w6852m(keep=metric value);set w6852o;length metric $120;array measured[*] dfdr_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6852m;set w6852m;format value best32.;run;
proc export data=w6852m outfile="%sysfunc(pathname(work))/W6852.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6852;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6852:;quit;
