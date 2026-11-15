/* New workflow W6853; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6853i;
length gene $80;
gene='p01';raw_p=0.005;output;
gene='p02';raw_p=0.7326531117357175;output;
gene='p03';raw_p=0.37572040596596823;output;
gene='p04';raw_p=1e-05;output;
gene='p05';raw_p=0.7767549304632526;output;
gene='p06';raw_p=0.9097263099652414;output;
gene='p07';raw_p=1;output;
gene='p08';raw_p=0.41225697286966534;output;
gene='p09';raw_p=0.6666250151566765;output;
gene='p10';raw_p=0.001;output;
gene='p11';raw_p=0.5802810639076009;output;
gene='p12';raw_p=0.9540393335697747;output;
run;
proc multtest inpvalues=w6853i dependentfdr out=w6853o noprint;run;
data w6853m(keep=metric value);set w6853o;length metric $120;array measured[*] dfdr_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6853m;set w6853m;format value best32.;run;
proc export data=w6853m outfile="%sysfunc(pathname(work))/W6853.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6853;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6853:;quit;
