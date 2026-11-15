/* New workflow W6805; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6805i;
length gene $80;
gene='p01';raw_p=0;output;
gene='p02';raw_p=0.5552046343008177;output;
gene='p03';raw_p=0.802659379179839;output;
gene='p04';raw_p=1;output;
gene='p05';raw_p=0.7769363526125047;output;
gene='p06';raw_p=0.3193875787898589;output;
gene='p07';raw_p=0.8;output;
gene='p08';raw_p=0.20386948571614283;output;
gene='p09';raw_p=0.9353018458249243;output;
gene='p10';raw_p=0.05;output;
gene='p11';raw_p=0.33853752198207165;output;
run;
proc multtest inpvalues=w6805i hoc out=w6805o noprint;run;
data w6805m(keep=metric value);set w6805o;length metric $120;array measured[*] hoc_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6805m;set w6805m;format value best32.;run;
proc export data=w6805m outfile="%sysfunc(pathname(work))/W6805.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6805;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6805:;quit;
