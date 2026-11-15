/* New workflow W6791; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6791i;
length gene $80;
gene='p01';raw_p=1;output;
gene='p02';raw_p=0.6995613528283394;output;
gene='p03';raw_p=0.003284230427851087;output;
gene='p04';raw_p=1;output;
gene='p05';raw_p=0.12840667202180578;output;
gene='p06';raw_p=0.11280587213791982;output;
gene='p07';raw_p=1e-05;output;
gene='p08';raw_p=0.7394291617323804;output;
gene='p09';raw_p=0.8397431029025644;output;
gene='p10';raw_p=0.001;output;
run;
proc multtest inpvalues=w6791i stepsid out=w6791o noprint;run;
data w6791m(keep=metric value);set w6791o;length metric $120;array measured[*] stpsid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6791m;set w6791m;format value best32.;run;
proc export data=w6791m outfile="%sysfunc(pathname(work))/W6791.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6791;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6791:;quit;
