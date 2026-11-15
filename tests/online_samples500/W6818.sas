/* New workflow W6818; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6818i;
length gene $80;
gene='p01';raw_p=0.05;output;
gene='p02';raw_p=0.04539960892977335;output;
gene='p03';raw_p=0.9254716560951048;output;
gene='p04';raw_p=0.01;output;
gene='p05';raw_p=0.7636706556678354;output;
gene='p06';raw_p=0.6885898778141698;output;
gene='p07';raw_p=0.05;output;
gene='p08';raw_p=0.6497048530567211;output;
gene='p09';raw_p=0.05311208885754837;output;
gene='p10';raw_p=0.01;output;
run;
proc multtest inpvalues=w6818i hoc out=w6818o noprint;run;
data w6818m(keep=metric value);set w6818o;length metric $120;array measured[*] hoc_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6818m;set w6818m;format value best32.;run;
proc export data=w6818m outfile="%sysfunc(pathname(work))/W6818.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6818;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6818:;quit;
