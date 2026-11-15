/* New workflow W6857; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6857i;
length gene $80;
gene='p01';raw_p=0.005;output;
gene='p02';raw_p=0.8916815323546345;output;
gene='p03';raw_p=0.8562457670491052;output;
gene='p04';raw_p=0.005;output;
gene='p05';raw_p=0.5941336800750017;output;
gene='p06';raw_p=0.022590101378467287;output;
gene='p07';raw_p=0.01;output;
gene='p08';raw_p=0.09436040773196286;output;
gene='p09';raw_p=0.9513533304482653;output;
run;
proc multtest inpvalues=w6857i dependentfdr out=w6857o noprint;run;
data w6857m(keep=metric value);set w6857o;length metric $120;array measured[*] dfdr_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6857m;set w6857m;format value best32.;run;
proc export data=w6857m outfile="%sysfunc(pathname(work))/W6857.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6857;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6857:;quit;
