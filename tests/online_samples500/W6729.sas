/* New workflow W6729; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6729i;
length gene $80;
gene='p01';raw_p=0.2;output;
gene='p02';raw_p=0.5990258458057192;output;
gene='p03';raw_p=0.2507846599838093;output;
gene='p04';raw_p=1e-05;output;
gene='p05';raw_p=0.011475066913485987;output;
gene='p06';raw_p=0.30567270147064496;output;
gene='p07';raw_p=0.2;output;
gene='p08';raw_p=0.5626419678833984;output;
run;
proc multtest inpvalues=w6729i bon out=w6729o noprint;run;
data w6729m(keep=metric value);set w6729o;length metric $120;array measured[*] bon_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6729m;set w6729m;format value best32.;run;
proc export data=w6729m outfile="%sysfunc(pathname(work))/W6729.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6729;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6729:;quit;
