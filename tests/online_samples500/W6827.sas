/* New workflow W6827; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6827i;
length gene $80;
gene='p01';raw_p=0.005;output;
gene='p02';raw_p=0.5370499087269588;output;
gene='p03';raw_p=0.06904743459703555;output;
gene='p04';raw_p=0.05;output;
gene='p05';raw_p=0.1095208183092039;output;
gene='p06';raw_p=0.13781670163223592;output;
run;
proc multtest inpvalues=w6827i fdr out=w6827o noprint;run;
data w6827m(keep=metric value);set w6827o;length metric $120;array measured[*] fdr_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6827m;set w6827m;format value best32.;run;
proc export data=w6827m outfile="%sysfunc(pathname(work))/W6827.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6827;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6827:;quit;
