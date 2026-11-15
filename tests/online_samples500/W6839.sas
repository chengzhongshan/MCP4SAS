/* New workflow W6839; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6839i;
length gene $80;
gene='p01';raw_p=0.001;output;
gene='p02';raw_p=0.9132686519873414;output;
gene='p03';raw_p=0.7824425973712346;output;
gene='p04';raw_p=0.2;output;
gene='p05';raw_p=0.6136499259021494;output;
gene='p06';raw_p=0.6057925551697421;output;
gene='p07';raw_p=0.005;output;
gene='p08';raw_p=0.11199481429424751;output;
gene='p09';raw_p=0.46036526662053057;output;
gene='p10';raw_p=1;output;
gene='p11';raw_p=0.39232361792982895;output;
run;
proc multtest inpvalues=w6839i fdr out=w6839o noprint;run;
data w6839m(keep=metric value);set w6839o;length metric $120;array measured[*] fdr_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6839m;set w6839m;format value best32.;run;
proc export data=w6839m outfile="%sysfunc(pathname(work))/W6839.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6839;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6839:;quit;
