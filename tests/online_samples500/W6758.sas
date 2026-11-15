/* New workflow W6758; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6758i;
length gene $80;
gene='p01';raw_p=0.2;output;
gene='p02';raw_p=0.7664043254093856;output;
gene='p03';raw_p=0.8511178134555072;output;
gene='p04';raw_p=0.005;output;
gene='p05';raw_p=0.3227504784362333;output;
gene='p06';raw_p=0.4387003924571532;output;
gene='p07';raw_p=0.001;output;
gene='p08';raw_p=0.7869801573441203;output;
gene='p09';raw_p=0.42702928861731093;output;
gene='p10';raw_p=0;output;
run;
proc multtest inpvalues=w6758i sid out=w6758o noprint;run;
data w6758m(keep=metric value);set w6758o;length metric $120;array measured[*] sid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6758m;set w6758m;format value best32.;run;
proc export data=w6758m outfile="%sysfunc(pathname(work))/W6758.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6758;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6758:;quit;
