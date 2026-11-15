/* New workflow W6858; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6858i;
length gene $80;
gene='p01';raw_p=0.2;output;
gene='p02';raw_p=0.6571083652880879;output;
gene='p03';raw_p=0.9938718913605037;output;
gene='p04';raw_p=0;output;
gene='p05';raw_p=0.5534225039482825;output;
gene='p06';raw_p=0.4670270435697047;output;
gene='p07';raw_p=0.2;output;
gene='p08';raw_p=0.03951296683210859;output;
gene='p09';raw_p=0.14973314603360932;output;
gene='p10';raw_p=1e-05;output;
run;
proc multtest inpvalues=w6858i dependentfdr out=w6858o noprint;run;
data w6858m(keep=metric value);set w6858o;length metric $120;array measured[*] dfdr_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6858m;set w6858m;format value best32.;run;
proc export data=w6858m outfile="%sysfunc(pathname(work))/W6858.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6858;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6858:;quit;
