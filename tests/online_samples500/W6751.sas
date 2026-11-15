/* New workflow W6751; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6751i;
length gene $80;
gene='p01';raw_p=0.001;output;
gene='p02';raw_p=0.5993940419660616;output;
gene='p03';raw_p=0.12612558911560678;output;
gene='p04';raw_p=1;output;
gene='p05';raw_p=0.13776700247202478;output;
gene='p06';raw_p=0.8226066524087613;output;
gene='p07';raw_p=0.001;output;
gene='p08';raw_p=0.4417778188833621;output;
gene='p09';raw_p=0.037946236789727084;output;
gene='p10';raw_p=0;output;
run;
proc multtest inpvalues=w6751i sid out=w6751o noprint;run;
data w6751m(keep=metric value);set w6751o;length metric $120;array measured[*] sid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6751m;set w6751m;format value best32.;run;
proc export data=w6751m outfile="%sysfunc(pathname(work))/W6751.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6751;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6751:;quit;
