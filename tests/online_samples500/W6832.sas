/* New workflow W6832; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6832i;
length gene $80;
gene='p01';raw_p=0.01;output;
gene='p02';raw_p=0.9052271833679483;output;
gene='p03';raw_p=0.9188955166811654;output;
gene='p04';raw_p=0.2;output;
gene='p05';raw_p=0.4771979339904333;output;
gene='p06';raw_p=0.9197739558319763;output;
gene='p07';raw_p=0.05;output;
gene='p08';raw_p=0.443013496048117;output;
gene='p09';raw_p=0.5806160738749798;output;
gene='p10';raw_p=0.8;output;
gene='p11';raw_p=0.45331217131222057;output;
run;
proc multtest inpvalues=w6832i fdr out=w6832o noprint;run;
data w6832m(keep=metric value);set w6832o;length metric $120;array measured[*] fdr_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6832m;set w6832m;format value best32.;run;
proc export data=w6832m outfile="%sysfunc(pathname(work))/W6832.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6832;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6832:;quit;
