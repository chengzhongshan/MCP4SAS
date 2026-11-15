/* New workflow W6796; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6796i;
length gene $80;
gene='p01';raw_p=0.8;output;
gene='p02';raw_p=0.9057527261732355;output;
gene='p03';raw_p=0.4176530389503923;output;
gene='p04';raw_p=0.05;output;
gene='p05';raw_p=0.9344797552628313;output;
gene='p06';raw_p=0.5819581103913637;output;
gene='p07';raw_p=0;output;
gene='p08';raw_p=0.422623694332365;output;
run;
proc multtest inpvalues=w6796i stepsid out=w6796o noprint;run;
data w6796m(keep=metric value);set w6796o;length metric $120;array measured[*] stpsid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6796m;set w6796m;format value best32.;run;
proc export data=w6796m outfile="%sysfunc(pathname(work))/W6796.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6796;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6796:;quit;
