/* New workflow W6748; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6748i;
length gene $80;
gene='p01';raw_p=1e-05;output;
gene='p02';raw_p=0.22867185952936375;output;
gene='p03';raw_p=0.8819293181668799;output;
gene='p04';raw_p=0.01;output;
gene='p05';raw_p=0.8294123062151235;output;
gene='p06';raw_p=0.026382762165803486;output;
gene='p07';raw_p=0.005;output;
run;
proc multtest inpvalues=w6748i sid out=w6748o noprint;run;
data w6748m(keep=metric value);set w6748o;length metric $120;array measured[*] sid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6748m;set w6748m;format value best32.;run;
proc export data=w6748m outfile="%sysfunc(pathname(work))/W6748.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6748;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6748:;quit;
