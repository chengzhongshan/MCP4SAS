/* New workflow W6872; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6872i;
length gene $80;
gene='p01';raw_p=0.8;output;
gene='p02';raw_p=0.7697755060009678;output;
gene='p03';raw_p=0.8854907148163846;output;
gene='p04';raw_p=0;output;
gene='p05';raw_p=0.9531123930503521;output;
gene='p06';raw_p=0.6936949222781671;output;
gene='p07';raw_p=0.8;output;
gene='p08';raw_p=0.306342710442716;output;
gene='p09';raw_p=0.3721089020905479;output;
gene='p10';raw_p=1e-05;output;
gene='p11';raw_p=0.894976967113155;output;
run;
data w6872o;set w6872i;retain adjusted 0;adjusted=max(adjusted,raw_p);run;
data w6872m(keep=metric value);set w6872o;length metric $120;array measured[*] adjusted;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6872m;set w6872m;format value best32.;run;
proc export data=w6872m outfile="%sysfunc(pathname(work))/W6872.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6872;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6872:;quit;
