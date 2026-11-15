/* New workflow W6810; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6810i;
length gene $80;
gene='p01';raw_p=1e-05;output;
gene='p02';raw_p=0.6033583484024371;output;
gene='p03';raw_p=0.7895952106412552;output;
gene='p04';raw_p=0.05;output;
gene='p05';raw_p=0.04858348531115608;output;
gene='p06';raw_p=0.0939008062840826;output;
gene='p07';raw_p=0.001;output;
gene='p08';raw_p=0.2599899418629854;output;
gene='p09';raw_p=0.10362348729646687;output;
run;
proc multtest inpvalues=w6810i hoc out=w6810o noprint;run;
data w6810m(keep=metric value);set w6810o;length metric $120;array measured[*] hoc_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6810m;set w6810m;format value best32.;run;
proc export data=w6810m outfile="%sysfunc(pathname(work))/W6810.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6810;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6810:;quit;
