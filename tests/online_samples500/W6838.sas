/* New workflow W6838; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6838i;
length gene $80;
gene='p01';raw_p=0.8;output;
gene='p02';raw_p=0.28360106272613994;output;
gene='p03';raw_p=0.4135731289613743;output;
gene='p04';raw_p=1e-05;output;
gene='p05';raw_p=0.11454485505048884;output;
gene='p06';raw_p=0.1822480895712546;output;
gene='p07';raw_p=1;output;
gene='p08';raw_p=0.31600480238144546;output;
gene='p09';raw_p=0.9490256510700771;output;
gene='p10';raw_p=0.8;output;
run;
proc multtest inpvalues=w6838i fdr out=w6838o noprint;run;
data w6838m(keep=metric value);set w6838o;length metric $120;array measured[*] fdr_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6838m;set w6838m;format value best32.;run;
proc export data=w6838m outfile="%sysfunc(pathname(work))/W6838.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6838;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6838:;quit;
