/* New workflow W6762; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6762i;
length gene $80;
gene='p01';raw_p=0;output;
gene='p02';raw_p=0.6387400900499903;output;
gene='p03';raw_p=0.8527363942132501;output;
gene='p04';raw_p=0.005;output;
gene='p05';raw_p=0.9657209020954346;output;
gene='p06';raw_p=0.9550267037283486;output;
gene='p07';raw_p=0.05;output;
gene='p08';raw_p=0.26492172740272524;output;
run;
proc multtest inpvalues=w6762i holm out=w6762o noprint;run;
data w6762m(keep=metric value);set w6762o;length metric $120;array measured[*] stpbon_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6762m;set w6762m;format value best32.;run;
proc export data=w6762m outfile="%sysfunc(pathname(work))/W6762.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6762;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6762:;quit;
