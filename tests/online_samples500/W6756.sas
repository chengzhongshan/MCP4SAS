/* New workflow W6756; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6756i;
length gene $80;
gene='p01';raw_p=1e-05;output;
gene='p02';raw_p=0.6787636315043689;output;
gene='p03';raw_p=0.7319075906169351;output;
gene='p04';raw_p=1;output;
gene='p05';raw_p=0.7301222019731909;output;
gene='p06';raw_p=0.5869469851536925;output;
gene='p07';raw_p=1;output;
gene='p08';raw_p=0.38128905333791585;output;
run;
proc multtest inpvalues=w6756i sid out=w6756o noprint;run;
data w6756m(keep=metric value);set w6756o;length metric $120;array measured[*] sid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6756m;set w6756m;format value best32.;run;
proc export data=w6756m outfile="%sysfunc(pathname(work))/W6756.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6756;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6756:;quit;
