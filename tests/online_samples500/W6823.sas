/* New workflow W6823; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6823i;
length gene $80;
gene='p01';raw_p=0;output;
gene='p02';raw_p=0.20654934374274225;output;
gene='p03';raw_p=0.4509060884571381;output;
gene='p04';raw_p=0.8;output;
gene='p05';raw_p=0.8923033631354456;output;
gene='p06';raw_p=0.3045375518997767;output;
gene='p07';raw_p=0.2;output;
gene='p08';raw_p=0.41678957858374643;output;
gene='p09';raw_p=0.800067903653101;output;
run;
proc multtest inpvalues=w6823i fdr out=w6823o noprint;run;
data w6823m(keep=metric value);set w6823o;length metric $120;array measured[*] fdr_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6823m;set w6823m;format value best32.;run;
proc export data=w6823m outfile="%sysfunc(pathname(work))/W6823.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6823;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6823:;quit;
