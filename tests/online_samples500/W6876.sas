/* New workflow W6876; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6876i;
length gene $80;
gene='p01';raw_p=0.2;output;
gene='p02';raw_p=0.5399291008200957;output;
gene='p03';raw_p=0.3034726217903788;output;
gene='p04';raw_p=0.005;output;
gene='p05';raw_p=0.3989433294528403;output;
gene='p06';raw_p=0.8698886534742248;output;
gene='p07';raw_p=1;output;
gene='p08';raw_p=0.5625759011452527;output;
run;
data w6876o;set w6876i;retain adjusted 0;adjusted=max(adjusted,raw_p);run;
data w6876m(keep=metric value);set w6876o;length metric $120;array measured[*] adjusted;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6876m;set w6876m;format value best32.;run;
proc export data=w6876m outfile="%sysfunc(pathname(work))/W6876.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6876;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6876:;quit;
