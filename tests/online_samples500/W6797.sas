/* New workflow W6797; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6797i;
length gene $80;
gene='p01';raw_p=0.8;output;
gene='p02';raw_p=0.38596970818224974;output;
gene='p03';raw_p=0.19991117580009032;output;
gene='p04';raw_p=1e-05;output;
gene='p05';raw_p=0.7868832395411158;output;
gene='p06';raw_p=0.7506550612782263;output;
gene='p07';raw_p=0.001;output;
gene='p08';raw_p=0.13767695200498686;output;
gene='p09';raw_p=0.5482461197471628;output;
run;
proc multtest inpvalues=w6797i stepsid out=w6797o noprint;run;
data w6797m(keep=metric value);set w6797o;length metric $120;array measured[*] stpsid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6797m;set w6797m;format value best32.;run;
proc export data=w6797m outfile="%sysfunc(pathname(work))/W6797.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6797;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6797:;quit;
