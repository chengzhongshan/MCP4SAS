/* New workflow W6788; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6788i;
length gene $80;
gene='p01';raw_p=0.001;output;
gene='p02';raw_p=0.942458227451922;output;
gene='p03';raw_p=0.0673190053357019;output;
gene='p04';raw_p=0.01;output;
gene='p05';raw_p=0.5664986817555094;output;
gene='p06';raw_p=0.4511993660696052;output;
gene='p07';raw_p=0.01;output;
run;
proc multtest inpvalues=w6788i stepsid out=w6788o noprint;run;
data w6788m(keep=metric value);set w6788o;length metric $120;array measured[*] stpsid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6788m;set w6788m;format value best32.;run;
proc export data=w6788m outfile="%sysfunc(pathname(work))/W6788.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6788;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6788:;quit;
