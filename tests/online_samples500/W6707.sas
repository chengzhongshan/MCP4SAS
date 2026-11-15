/* New workflow W6707; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6707i;
length gene $80;
gene='p01';raw_p=0.001;output;
gene='p02';raw_p=0.26190005155487195;output;
gene='p03';raw_p=0.8444220982011812;output;
gene='p04';raw_p=1;output;
gene='p05';raw_p=0.6099123474557259;output;
gene='p06';raw_p=0.10334443169257201;output;
run;
data w6707o;set w6707i;bon_p=min(1,6*raw_p);sid_p=1-(1-raw_p)**6;run;
data w6707m(keep=metric value);set w6707o;length metric $120;array measured[*] bon_p sid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6707m;set w6707m;format value best32.;run;
proc export data=w6707m outfile="%sysfunc(pathname(work))/W6707.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6707;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6707:;quit;
