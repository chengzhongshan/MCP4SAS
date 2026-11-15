/* New workflow W6842; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6842i;
length gene $80;
gene='p01';raw_p=0.005;output;
gene='p02';raw_p=0.7650627280652915;output;
gene='p03';raw_p=0.8625400432338429;output;
gene='p04';raw_p=0;output;
gene='p05';raw_p=0.5017841102108758;output;
gene='p06';raw_p=0.2724129065005203;output;
gene='p07';raw_p=1;output;
gene='p08';raw_p=0.6036710849743054;output;
run;
proc multtest inpvalues=w6842i dependentfdr out=w6842o noprint;run;
data w6842m(keep=metric value);set w6842o;length metric $120;array measured[*] dfdr_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6842m;set w6842m;format value best32.;run;
proc export data=w6842m outfile="%sysfunc(pathname(work))/W6842.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6842;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6842:;quit;
