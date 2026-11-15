/* New workflow W6752; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6752i;
length gene $80;
gene='p01';raw_p=1e-05;output;
gene='p02';raw_p=0.4207817407997114;output;
gene='p03';raw_p=0.8327756516008553;output;
gene='p04';raw_p=1;output;
gene='p05';raw_p=0.6692137209495813;output;
gene='p06';raw_p=0.15871934215480443;output;
gene='p07';raw_p=0.05;output;
gene='p08';raw_p=0.24986129743283525;output;
gene='p09';raw_p=0.8752157792133408;output;
gene='p10';raw_p=0.05;output;
gene='p11';raw_p=0.7553042865311622;output;
run;
proc multtest inpvalues=w6752i sid out=w6752o noprint;run;
data w6752m(keep=metric value);set w6752o;length metric $120;array measured[*] sid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6752m;set w6752m;format value best32.;run;
proc export data=w6752m outfile="%sysfunc(pathname(work))/W6752.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6752;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6752:;quit;
