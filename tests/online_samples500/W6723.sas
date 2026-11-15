/* New workflow W6723; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6723i;
length gene $80;
gene='p01';raw_p=0;output;
gene='p02';raw_p=0.5979388084397166;output;
gene='p03';raw_p=0.5397712279403287;output;
gene='p04';raw_p=0.8;output;
gene='p05';raw_p=0.019871810340893692;output;
gene='p06';raw_p=0.3894035129353012;output;
gene='p07';raw_p=0.005;output;
gene='p08';raw_p=0.492520159831328;output;
gene='p09';raw_p=0.5717995335163532;output;
run;
proc multtest inpvalues=w6723i bon out=w6723o noprint;run;
data w6723m(keep=metric value);set w6723o;length metric $120;array measured[*] bon_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6723m;set w6723m;format value best32.;run;
proc export data=w6723m outfile="%sysfunc(pathname(work))/W6723.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6723;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6723:;quit;
