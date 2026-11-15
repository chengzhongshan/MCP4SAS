/* New workflow W6732; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6732i;
length gene $80;
gene='p01';raw_p=0.005;output;
gene='p02';raw_p=0.21122074755527187;output;
gene='p03';raw_p=0.6626045302339372;output;
gene='p04';raw_p=0.01;output;
gene='p05';raw_p=0.20427980014121216;output;
gene='p06';raw_p=0.9996598161153621;output;
gene='p07';raw_p=1e-05;output;
gene='p08';raw_p=0.06499245723617442;output;
gene='p09';raw_p=0.9337218595020127;output;
gene='p10';raw_p=0.2;output;
gene='p11';raw_p=0.9013007893277868;output;
run;
proc multtest inpvalues=w6732i bon out=w6732o noprint;run;
data w6732m(keep=metric value);set w6732o;length metric $120;array measured[*] bon_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6732m;set w6732m;format value best32.;run;
proc export data=w6732m outfile="%sysfunc(pathname(work))/W6732.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6732;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6732:;quit;
