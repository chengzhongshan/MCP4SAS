/* New workflow W6822; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6822i;
length gene $80;
gene='p01';raw_p=0.8;output;
gene='p02';raw_p=0.6980226811120436;output;
gene='p03';raw_p=0.10520602704534399;output;
gene='p04';raw_p=0.8;output;
gene='p05';raw_p=0.581814499509224;output;
gene='p06';raw_p=0.8456088548565251;output;
gene='p07';raw_p=0.8;output;
gene='p08';raw_p=0.010807933020534843;output;
run;
proc multtest inpvalues=w6822i fdr out=w6822o noprint;run;
data w6822m(keep=metric value);set w6822o;length metric $120;array measured[*] fdr_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6822m;set w6822m;format value best32.;run;
proc export data=w6822m outfile="%sysfunc(pathname(work))/W6822.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6822;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6822:;quit;
