/* New workflow W6743; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6743i;
length gene $80;
gene='p01';raw_p=0.005;output;
gene='p02';raw_p=0.5837903128936623;output;
gene='p03';raw_p=0.5582623531874424;output;
gene='p04';raw_p=0.001;output;
gene='p05';raw_p=0.7510433073087817;output;
gene='p06';raw_p=0.3096977255517025;output;
gene='p07';raw_p=0.01;output;
gene='p08';raw_p=0.2657396957160768;output;
gene='p09';raw_p=0.5268546253428602;output;
run;
proc multtest inpvalues=w6743i sid out=w6743o noprint;run;
data w6743m(keep=metric value);set w6743o;length metric $120;array measured[*] sid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6743m;set w6743m;format value best32.;run;
proc export data=w6743m outfile="%sysfunc(pathname(work))/W6743.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6743;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6743:;quit;
