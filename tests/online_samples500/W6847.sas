/* New workflow W6847; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6847i;
length gene $80;
gene='p01';raw_p=1e-05;output;
gene='p02';raw_p=0.3723797582772942;output;
gene='p03';raw_p=0.19103439010317425;output;
gene='p04';raw_p=1e-05;output;
gene='p05';raw_p=0.5894360643468998;output;
gene='p06';raw_p=0.10410846218007686;output;
run;
proc multtest inpvalues=w6847i dependentfdr out=w6847o noprint;run;
data w6847m(keep=metric value);set w6847o;length metric $120;array measured[*] dfdr_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6847m;set w6847m;format value best32.;run;
proc export data=w6847m outfile="%sysfunc(pathname(work))/W6847.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6847;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6847:;quit;
