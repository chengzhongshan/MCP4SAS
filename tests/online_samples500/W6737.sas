/* New workflow W6737; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6737i;
length gene $80;
gene='p01';raw_p=1;output;
gene='p02';raw_p=0.34509837944106236;output;
gene='p03';raw_p=0.8258099437983663;output;
gene='p04';raw_p=0.8;output;
gene='p05';raw_p=0.40327189721847134;output;
gene='p06';raw_p=0.20581004115253254;output;
gene='p07';raw_p=1;output;
gene='p08';raw_p=0.9841851266820943;output;
gene='p09';raw_p=0.37262151155494105;output;
run;
proc multtest inpvalues=w6737i bon out=w6737o noprint;run;
data w6737m(keep=metric value);set w6737o;length metric $120;array measured[*] bon_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6737m;set w6737m;format value best32.;run;
proc export data=w6737m outfile="%sysfunc(pathname(work))/W6737.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6737;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6737:;quit;
