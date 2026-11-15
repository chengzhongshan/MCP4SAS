/* New workflow W6854; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6854i;
length gene $80;
gene='p01';raw_p=0.8;output;
gene='p02';raw_p=0.7201869429360801;output;
gene='p03';raw_p=0.19725558549050437;output;
gene='p04';raw_p=1;output;
gene='p05';raw_p=0.09521610529159907;output;
gene='p06';raw_p=0.08262915275346949;output;
run;
proc multtest inpvalues=w6854i dependentfdr out=w6854o noprint;run;
data w6854m(keep=metric value);set w6854o;length metric $120;array measured[*] dfdr_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6854m;set w6854m;format value best32.;run;
proc export data=w6854m outfile="%sysfunc(pathname(work))/W6854.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6854;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6854:;quit;
