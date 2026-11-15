/* New workflow W6848; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6848i;
length gene $80;
gene='p01';raw_p=0.2;output;
gene='p02';raw_p=0.9271561739210272;output;
gene='p03';raw_p=0.6445854284572557;output;
gene='p04';raw_p=0.05;output;
gene='p05';raw_p=0.542747742158415;output;
gene='p06';raw_p=0.5410312148733551;output;
gene='p07';raw_p=1;output;
run;
proc multtest inpvalues=w6848i dependentfdr out=w6848o noprint;run;
data w6848m(keep=metric value);set w6848o;length metric $120;array measured[*] dfdr_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6848m;set w6848m;format value best32.;run;
proc export data=w6848m outfile="%sysfunc(pathname(work))/W6848.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6848;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6848:;quit;
