/* New workflow W6846; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6846i;
length gene $80;
gene='p01';raw_p=1e-05;output;
gene='p02';raw_p=0.45888341710197456;output;
gene='p03';raw_p=0.1432848131141079;output;
gene='p04';raw_p=0.2;output;
gene='p05';raw_p=0.49604631458312753;output;
gene='p06';raw_p=0.017642353819588785;output;
gene='p07';raw_p=0.8;output;
gene='p08';raw_p=0.9980938593834718;output;
gene='p09';raw_p=0.47167750930630137;output;
gene='p10';raw_p=1;output;
gene='p11';raw_p=0.9023123962147689;output;
gene='p12';raw_p=0.15713420107298293;output;
run;
proc multtest inpvalues=w6846i dependentfdr out=w6846o noprint;run;
data w6846m(keep=metric value);set w6846o;length metric $120;array measured[*] dfdr_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6846m;set w6846m;format value best32.;run;
proc export data=w6846m outfile="%sysfunc(pathname(work))/W6846.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6846;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6846:;quit;
