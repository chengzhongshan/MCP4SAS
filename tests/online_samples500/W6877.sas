/* New workflow W6877; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6877i;
length gene $80;
gene='p01';raw_p=0.05;output;
gene='p02';raw_p=0.03514881570770856;output;
gene='p03';raw_p=0.8584080660060959;output;
gene='p04';raw_p=0.8;output;
gene='p05';raw_p=0.06720297899263983;output;
gene='p06';raw_p=0.272909184665456;output;
gene='p07';raw_p=0.01;output;
gene='p08';raw_p=0.5349966573421796;output;
gene='p09';raw_p=0.35977465676826925;output;
run;
data w6877o;set w6877i;retain adjusted 0;adjusted=max(adjusted,raw_p);run;
data w6877m(keep=metric value);set w6877o;length metric $120;array measured[*] adjusted;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6877m;set w6877m;format value best32.;run;
proc export data=w6877m outfile="%sysfunc(pathname(work))/W6877.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6877;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6877:;quit;
