/* New workflow W6801; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6801i;
length gene $80;
gene='p01';raw_p=1;output;
gene='p02';raw_p=0.36448096203002767;output;
gene='p03';raw_p=0.5277644154080371;output;
gene='p04';raw_p=0.2;output;
gene='p05';raw_p=0.6793096066345458;output;
gene='p06';raw_p=0.7477924918035314;output;
gene='p07';raw_p=0.005;output;
run;
proc multtest inpvalues=w6801i hoc out=w6801o noprint;run;
data w6801m(keep=metric value);set w6801o;length metric $120;array measured[*] hoc_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6801m;set w6801m;format value best32.;run;
proc export data=w6801m outfile="%sysfunc(pathname(work))/W6801.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6801;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6801:;quit;
