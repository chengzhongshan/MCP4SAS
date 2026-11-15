/* New workflow W6829; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6829i;
length gene $80;
gene='p01';raw_p=0.01;output;
gene='p02';raw_p=0.13846433760385313;output;
gene='p03';raw_p=0.33319544023154024;output;
gene='p04';raw_p=0.2;output;
gene='p05';raw_p=0.03590511101917482;output;
gene='p06';raw_p=0.5097074848364502;output;
gene='p07';raw_p=0.01;output;
gene='p08';raw_p=0.46877902435044827;output;
run;
proc multtest inpvalues=w6829i fdr out=w6829o noprint;run;
data w6829m(keep=metric value);set w6829o;length metric $120;array measured[*] fdr_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6829m;set w6829m;format value best32.;run;
proc export data=w6829m outfile="%sysfunc(pathname(work))/W6829.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6829;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6829:;quit;
