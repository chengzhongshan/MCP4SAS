/* New workflow W6789; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6789i;
length gene $80;
gene='p01';raw_p=1e-05;output;
gene='p02';raw_p=0.8960505334849023;output;
gene='p03';raw_p=0.4084851914800859;output;
gene='p04';raw_p=0.2;output;
gene='p05';raw_p=0.14888769824058556;output;
gene='p06';raw_p=0.9959658581809193;output;
gene='p07';raw_p=1;output;
gene='p08';raw_p=0.4219500256048311;output;
run;
proc multtest inpvalues=w6789i stepsid out=w6789o noprint;run;
data w6789m(keep=metric value);set w6789o;length metric $120;array measured[*] stpsid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6789m;set w6789m;format value best32.;run;
proc export data=w6789m outfile="%sysfunc(pathname(work))/W6789.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6789;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6789:;quit;
