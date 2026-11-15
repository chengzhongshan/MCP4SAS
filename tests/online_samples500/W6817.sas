/* New workflow W6817; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6817i;
length gene $80;
gene='p01';raw_p=0.001;output;
gene='p02';raw_p=0.29906768909503256;output;
gene='p03';raw_p=0.3540301568792419;output;
gene='p04';raw_p=0.2;output;
gene='p05';raw_p=0.1442396674610733;output;
gene='p06';raw_p=0.7103242208513936;output;
gene='p07';raw_p=1;output;
gene='p08';raw_p=0.9164175499978653;output;
gene='p09';raw_p=0.19474703198313859;output;
run;
proc multtest inpvalues=w6817i hoc out=w6817o noprint;run;
data w6817m(keep=metric value);set w6817o;length metric $120;array measured[*] hoc_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6817m;set w6817m;format value best32.;run;
proc export data=w6817m outfile="%sysfunc(pathname(work))/W6817.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6817;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6817:;quit;
