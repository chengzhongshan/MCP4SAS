/* New workflow W6795; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6795i;
length gene $80;
gene='p01';raw_p=0;output;
gene='p02';raw_p=0.5762685505488622;output;
gene='p03';raw_p=0.18228227954631215;output;
gene='p04';raw_p=0;output;
gene='p05';raw_p=0.2581501980590961;output;
gene='p06';raw_p=0.31121115268275856;output;
gene='p07';raw_p=1;output;
run;
proc multtest inpvalues=w6795i stepsid out=w6795o noprint;run;
data w6795m(keep=metric value);set w6795o;length metric $120;array measured[*] stpsid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6795m;set w6795m;format value best32.;run;
proc export data=w6795m outfile="%sysfunc(pathname(work))/W6795.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6795;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6795:;quit;
