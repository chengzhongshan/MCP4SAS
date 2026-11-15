/* New workflow W6768; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6768i;
length gene $80;
gene='p01';raw_p=0.01;output;
gene='p02';raw_p=0.9636043613530916;output;
gene='p03';raw_p=0.4773659161943671;output;
gene='p04';raw_p=1e-05;output;
gene='p05';raw_p=0.7582216733543532;output;
gene='p06';raw_p=0.5444423668601996;output;
gene='p07';raw_p=0.001;output;
run;
proc multtest inpvalues=w6768i holm out=w6768o noprint;run;
data w6768m(keep=metric value);set w6768o;length metric $120;array measured[*] stpbon_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6768m;set w6768m;format value best32.;run;
proc export data=w6768m outfile="%sysfunc(pathname(work))/W6768.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6768;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6768:;quit;
