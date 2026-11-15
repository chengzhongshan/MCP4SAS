/* New workflow W6777; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6777i;
length gene $80;
gene='p01';raw_p=0.005;output;
gene='p02';raw_p=0.581048156467536;output;
gene='p03';raw_p=0.9956466339538563;output;
gene='p04';raw_p=0.8;output;
gene='p05';raw_p=0.8134385308278336;output;
gene='p06';raw_p=0.6580152072706931;output;
gene='p07';raw_p=1;output;
gene='p08';raw_p=0.5672254754509841;output;
gene='p09';raw_p=0.3134399672221564;output;
run;
proc multtest inpvalues=w6777i holm out=w6777o noprint;run;
data w6777m(keep=metric value);set w6777o;length metric $120;array measured[*] stpbon_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6777m;set w6777m;format value best32.;run;
proc export data=w6777m outfile="%sysfunc(pathname(work))/W6777.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6777;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6777:;quit;
