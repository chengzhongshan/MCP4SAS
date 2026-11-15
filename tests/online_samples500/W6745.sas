/* New workflow W6745; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6745i;
length gene $80;
gene='p01';raw_p=1;output;
gene='p02';raw_p=0.8388241762155615;output;
gene='p03';raw_p=0.690349297016074;output;
gene='p04';raw_p=0.001;output;
gene='p05';raw_p=0.2825204513890962;output;
gene='p06';raw_p=0.4042276286067945;output;
gene='p07';raw_p=0.001;output;
gene='p08';raw_p=0.6671365824077519;output;
gene='p09';raw_p=0.7530910300757496;output;
gene='p10';raw_p=0.2;output;
gene='p11';raw_p=0.6316275730458919;output;
run;
proc multtest inpvalues=w6745i sid out=w6745o noprint;run;
data w6745m(keep=metric value);set w6745o;length metric $120;array measured[*] sid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6745m;set w6745m;format value best32.;run;
proc export data=w6745m outfile="%sysfunc(pathname(work))/W6745.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6745;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6745:;quit;
