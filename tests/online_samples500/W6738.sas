/* New workflow W6738; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6738i;
length gene $80;
gene='p01';raw_p=0.05;output;
gene='p02';raw_p=0.028645986742280916;output;
gene='p03';raw_p=0.5206096447128451;output;
gene='p04';raw_p=0.05;output;
gene='p05';raw_p=0.6591053988757131;output;
gene='p06';raw_p=0.33089872766799844;output;
gene='p07';raw_p=0.001;output;
gene='p08';raw_p=0.25424451875900134;output;
gene='p09';raw_p=0.2466889729567704;output;
gene='p10';raw_p=0.001;output;
run;
proc multtest inpvalues=w6738i bon out=w6738o noprint;run;
data w6738m(keep=metric value);set w6738o;length metric $120;array measured[*] bon_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6738m;set w6738m;format value best32.;run;
proc export data=w6738m outfile="%sysfunc(pathname(work))/W6738.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6738;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6738:;quit;
