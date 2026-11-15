/* New workflow W6787; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6787i;
length gene $80;
gene='p01';raw_p=0.8;output;
gene='p02';raw_p=0.528715609796994;output;
gene='p03';raw_p=0.7228352083169993;output;
gene='p04';raw_p=1e-05;output;
gene='p05';raw_p=0.37615847294390936;output;
gene='p06';raw_p=0.39750851568534484;output;
run;
proc multtest inpvalues=w6787i stepsid out=w6787o noprint;run;
data w6787m(keep=metric value);set w6787o;length metric $120;array measured[*] stpsid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6787m;set w6787m;format value best32.;run;
proc export data=w6787m outfile="%sysfunc(pathname(work))/W6787.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6787;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6787:;quit;
