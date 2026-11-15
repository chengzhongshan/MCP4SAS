/* New workflow W6744; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6744i;
length gene $80;
gene='p01';raw_p=0.05;output;
gene='p02';raw_p=0.18786639121258542;output;
gene='p03';raw_p=0.4272174508687552;output;
gene='p04';raw_p=0.05;output;
gene='p05';raw_p=0.17430266675637063;output;
gene='p06';raw_p=0.6371431697075898;output;
gene='p07';raw_p=1;output;
gene='p08';raw_p=0.12183596417655307;output;
gene='p09';raw_p=0.588388236800892;output;
gene='p10';raw_p=0.005;output;
run;
proc multtest inpvalues=w6744i sid out=w6744o noprint;run;
data w6744m(keep=metric value);set w6744o;length metric $120;array measured[*] sid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6744m;set w6744m;format value best32.;run;
proc export data=w6744m outfile="%sysfunc(pathname(work))/W6744.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6744;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6744:;quit;
