/* New workflow W6764; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6764i;
length gene $80;
gene='p01';raw_p=0.2;output;
gene='p02';raw_p=0.10511935362638558;output;
gene='p03';raw_p=0.58187681884717;output;
gene='p04';raw_p=0;output;
gene='p05';raw_p=0.007450854995026068;output;
gene='p06';raw_p=0.012781248075719787;output;
gene='p07';raw_p=1;output;
gene='p08';raw_p=0.45258014463905616;output;
gene='p09';raw_p=0.7072015284139488;output;
gene='p10';raw_p=0.2;output;
run;
proc multtest inpvalues=w6764i holm out=w6764o noprint;run;
data w6764m(keep=metric value);set w6764o;length metric $120;array measured[*] stpbon_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6764m;set w6764m;format value best32.;run;
proc export data=w6764m outfile="%sysfunc(pathname(work))/W6764.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6764;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6764:;quit;
