/* New workflow W6802; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6802i;
length gene $80;
gene='p01';raw_p=0.8;output;
gene='p02';raw_p=0.8861490461903007;output;
gene='p03';raw_p=0.57892062608825;output;
gene='p04';raw_p=0.01;output;
gene='p05';raw_p=0.05642377916062824;output;
gene='p06';raw_p=0.11745130458499631;output;
gene='p07';raw_p=0.05;output;
gene='p08';raw_p=0.7908405500489267;output;
run;
proc multtest inpvalues=w6802i hoc out=w6802o noprint;run;
data w6802m(keep=metric value);set w6802o;length metric $120;array measured[*] hoc_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6802m;set w6802m;format value best32.;run;
proc export data=w6802m outfile="%sysfunc(pathname(work))/W6802.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6802;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6802:;quit;
