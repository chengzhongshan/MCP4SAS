/* New workflow W6779; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6779i;
length gene $80;
gene='p01';raw_p=0.2;output;
gene='p02';raw_p=0.4995938420440882;output;
gene='p03';raw_p=0.5043064827938125;output;
gene='p04';raw_p=0.005;output;
gene='p05';raw_p=0.1521273284403053;output;
gene='p06';raw_p=0.6742615837319395;output;
gene='p07';raw_p=1;output;
gene='p08';raw_p=0.8367072615942991;output;
gene='p09';raw_p=0.25504203948944093;output;
gene='p10';raw_p=0.001;output;
gene='p11';raw_p=0.09698340049999177;output;
run;
proc multtest inpvalues=w6779i holm out=w6779o noprint;run;
data w6779m(keep=metric value);set w6779o;length metric $120;array measured[*] stpbon_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6779m;set w6779m;format value best32.;run;
proc export data=w6779m outfile="%sysfunc(pathname(work))/W6779.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6779;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6779:;quit;
