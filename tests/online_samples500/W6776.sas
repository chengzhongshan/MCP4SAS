/* New workflow W6776; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6776i;
length gene $80;
gene='p01';raw_p=0.005;output;
gene='p02';raw_p=0.6832843287810451;output;
gene='p03';raw_p=0.5190521674307345;output;
gene='p04';raw_p=1;output;
gene='p05';raw_p=0.7666321257454575;output;
gene='p06';raw_p=0.7892359252599208;output;
gene='p07';raw_p=0.05;output;
gene='p08';raw_p=0.5713146003933417;output;
run;
proc multtest inpvalues=w6776i holm out=w6776o noprint;run;
data w6776m(keep=metric value);set w6776o;length metric $120;array measured[*] stpbon_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6776m;set w6776m;format value best32.;run;
proc export data=w6776m outfile="%sysfunc(pathname(work))/W6776.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6776;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6776:;quit;
