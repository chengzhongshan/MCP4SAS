/* New workflow W6734; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6734i;
length gene $80;
gene='p01';raw_p=0.2;output;
gene='p02';raw_p=0.9344100817706156;output;
gene='p03';raw_p=0.5417112761500014;output;
gene='p04';raw_p=0;output;
gene='p05';raw_p=0.34480261155112524;output;
gene='p06';raw_p=0.741736916557779;output;
run;
proc multtest inpvalues=w6734i bon out=w6734o noprint;run;
data w6734m(keep=metric value);set w6734o;length metric $120;array measured[*] bon_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6734m;set w6734m;format value best32.;run;
proc export data=w6734m outfile="%sysfunc(pathname(work))/W6734.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6734;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6734:;quit;
