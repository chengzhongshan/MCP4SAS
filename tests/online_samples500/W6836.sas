/* New workflow W6836; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6836i;
length gene $80;
gene='p01';raw_p=0;output;
gene='p02';raw_p=0.8943979599070606;output;
gene='p03';raw_p=0.16808946676747205;output;
gene='p04';raw_p=1;output;
gene='p05';raw_p=0.05735453157998982;output;
gene='p06';raw_p=0.7957151212240199;output;
gene='p07';raw_p=1e-05;output;
gene='p08';raw_p=0.874676878762564;output;
run;
proc multtest inpvalues=w6836i fdr out=w6836o noprint;run;
data w6836m(keep=metric value);set w6836o;length metric $120;array measured[*] fdr_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6836m;set w6836m;format value best32.;run;
proc export data=w6836m outfile="%sysfunc(pathname(work))/W6836.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6836;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6836:;quit;
