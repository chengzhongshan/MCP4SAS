/* New workflow W6833; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6833i;
length gene $80;
gene='p01';raw_p=0.05;output;
gene='p02';raw_p=0.5372680911853758;output;
gene='p03';raw_p=0.0623095941116345;output;
gene='p04';raw_p=0.8;output;
gene='p05';raw_p=0.04224361465428994;output;
gene='p06';raw_p=0.2612304685349538;output;
gene='p07';raw_p=0.005;output;
gene='p08';raw_p=0.5773783602960968;output;
gene='p09';raw_p=0.9182844345514688;output;
gene='p10';raw_p=0.2;output;
gene='p11';raw_p=0.549229972191376;output;
gene='p12';raw_p=0.9280819178749439;output;
run;
proc multtest inpvalues=w6833i fdr out=w6833o noprint;run;
data w6833m(keep=metric value);set w6833o;length metric $120;array measured[*] fdr_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6833m;set w6833m;format value best32.;run;
proc export data=w6833m outfile="%sysfunc(pathname(work))/W6833.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6833;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6833:;quit;
