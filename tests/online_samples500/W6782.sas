/* New workflow W6782; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6782i;
length gene $80;
gene='p01';raw_p=0.05;output;
gene='p02';raw_p=0.937360628254767;output;
gene='p03';raw_p=0.22379502362211257;output;
gene='p04';raw_p=0;output;
gene='p05';raw_p=0.3742773440157121;output;
gene='p06';raw_p=0.23443265106569156;output;
gene='p07';raw_p=0.005;output;
gene='p08';raw_p=0.2800114470418753;output;
run;
proc multtest inpvalues=w6782i stepsid out=w6782o noprint;run;
data w6782m(keep=metric value);set w6782o;length metric $120;array measured[*] stpsid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6782m;set w6782m;format value best32.;run;
proc export data=w6782m outfile="%sysfunc(pathname(work))/W6782.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6782;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6782:;quit;
