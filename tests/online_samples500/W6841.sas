/* New workflow W6841; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6841i;
length gene $80;
gene='p01';raw_p=0.001;output;
gene='p02';raw_p=0.684864711951368;output;
gene='p03';raw_p=0.6276044732460124;output;
gene='p04';raw_p=0.05;output;
gene='p05';raw_p=0.42602367631981497;output;
gene='p06';raw_p=0.3421399307163673;output;
gene='p07';raw_p=0.001;output;
run;
proc multtest inpvalues=w6841i dependentfdr out=w6841o noprint;run;
data w6841m(keep=metric value);set w6841o;length metric $120;array measured[*] dfdr_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6841m;set w6841m;format value best32.;run;
proc export data=w6841m outfile="%sysfunc(pathname(work))/W6841.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6841;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6841:;quit;
