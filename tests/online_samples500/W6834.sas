/* New workflow W6834; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6834i;
length gene $80;
gene='p01';raw_p=0.2;output;
gene='p02';raw_p=0.13089266298668156;output;
gene='p03';raw_p=0.1836269123355696;output;
gene='p04';raw_p=0.05;output;
gene='p05';raw_p=0.4251753815749686;output;
gene='p06';raw_p=0.065230392788032;output;
run;
proc multtest inpvalues=w6834i fdr out=w6834o noprint;run;
data w6834m(keep=metric value);set w6834o;length metric $120;array measured[*] fdr_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6834m;set w6834m;format value best32.;run;
proc export data=w6834m outfile="%sysfunc(pathname(work))/W6834.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6834;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6834:;quit;
