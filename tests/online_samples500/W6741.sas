/* New workflow W6741; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6741i;
length gene $80;
gene='p01';raw_p=0.8;output;
gene='p02';raw_p=0.23892052826825816;output;
gene='p03';raw_p=0.3842549646746972;output;
gene='p04';raw_p=0.005;output;
gene='p05';raw_p=0.696637307498599;output;
gene='p06';raw_p=0.24734528797535626;output;
gene='p07';raw_p=0.01;output;
run;
proc multtest inpvalues=w6741i sid out=w6741o noprint;run;
data w6741m(keep=metric value);set w6741o;length metric $120;array measured[*] sid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6741m;set w6741m;format value best32.;run;
proc export data=w6741m outfile="%sysfunc(pathname(work))/W6741.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6741;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6741:;quit;
