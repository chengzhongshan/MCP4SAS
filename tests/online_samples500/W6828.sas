/* New workflow W6828; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6828i;
length gene $80;
gene='p01';raw_p=0.05;output;
gene='p02';raw_p=0.166676592208012;output;
gene='p03';raw_p=0.6047590648117657;output;
gene='p04';raw_p=1;output;
gene='p05';raw_p=0.3877253761736872;output;
gene='p06';raw_p=0.23576803913354716;output;
gene='p07';raw_p=0.01;output;
run;
proc multtest inpvalues=w6828i fdr out=w6828o noprint;run;
data w6828m(keep=metric value);set w6828o;length metric $120;array measured[*] fdr_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6828m;set w6828m;format value best32.;run;
proc export data=w6828m outfile="%sysfunc(pathname(work))/W6828.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6828;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6828:;quit;
