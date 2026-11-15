/* New workflow W6811; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6811i;
length gene $80;
gene='p01';raw_p=1;output;
gene='p02';raw_p=0.26168668706167164;output;
gene='p03';raw_p=0.5036695341407577;output;
gene='p04';raw_p=0.001;output;
gene='p05';raw_p=0.443978811812866;output;
gene='p06';raw_p=0.22058836249128888;output;
gene='p07';raw_p=1;output;
gene='p08';raw_p=0.8508979323737706;output;
gene='p09';raw_p=0.5268883523955832;output;
gene='p10';raw_p=0.005;output;
run;
proc multtest inpvalues=w6811i hoc out=w6811o noprint;run;
data w6811m(keep=metric value);set w6811o;length metric $120;array measured[*] hoc_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6811m;set w6811m;format value best32.;run;
proc export data=w6811m outfile="%sysfunc(pathname(work))/W6811.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6811;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6811:;quit;
