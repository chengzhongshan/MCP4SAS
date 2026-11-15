/* New workflow W6844; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6844i;
length gene $80;
gene='p01';raw_p=0.001;output;
gene='p02';raw_p=0.2454522521870347;output;
gene='p03';raw_p=0.10239353558231867;output;
gene='p04';raw_p=0.005;output;
gene='p05';raw_p=0.7902962632832041;output;
gene='p06';raw_p=0.19293552471840691;output;
gene='p07';raw_p=0.001;output;
gene='p08';raw_p=0.7234335752279584;output;
gene='p09';raw_p=0.5068656758206871;output;
gene='p10';raw_p=0.2;output;
run;
proc multtest inpvalues=w6844i dependentfdr out=w6844o noprint;run;
data w6844m(keep=metric value);set w6844o;length metric $120;array measured[*] dfdr_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6844m;set w6844m;format value best32.;run;
proc export data=w6844m outfile="%sysfunc(pathname(work))/W6844.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6844;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6844:;quit;
