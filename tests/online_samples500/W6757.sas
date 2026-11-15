/* New workflow W6757; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6757i;
length gene $80;
gene='p01';raw_p=0.001;output;
gene='p02';raw_p=0.859477629724514;output;
gene='p03';raw_p=0.25077049701083165;output;
gene='p04';raw_p=0.01;output;
gene='p05';raw_p=0.5453398305505074;output;
gene='p06';raw_p=0.5603948782413167;output;
gene='p07';raw_p=1;output;
gene='p08';raw_p=0.6809029239583185;output;
gene='p09';raw_p=0.24132261122010668;output;
run;
proc multtest inpvalues=w6757i sid out=w6757o noprint;run;
data w6757m(keep=metric value);set w6757o;length metric $120;array measured[*] sid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6757m;set w6757m;format value best32.;run;
proc export data=w6757m outfile="%sysfunc(pathname(work))/W6757.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6757;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6757:;quit;
