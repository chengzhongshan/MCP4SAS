/* New workflow W6835; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6835i;
length gene $80;
gene='p01';raw_p=0.8;output;
gene='p02';raw_p=0.16956611391358345;output;
gene='p03';raw_p=0.09642359338886286;output;
gene='p04';raw_p=0.01;output;
gene='p05';raw_p=0.06382301703932747;output;
gene='p06';raw_p=0.412307215347552;output;
gene='p07';raw_p=0;output;
run;
proc multtest inpvalues=w6835i fdr out=w6835o noprint;run;
data w6835m(keep=metric value);set w6835o;length metric $120;array measured[*] fdr_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6835m;set w6835m;format value best32.;run;
proc export data=w6835m outfile="%sysfunc(pathname(work))/W6835.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6835;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6835:;quit;
