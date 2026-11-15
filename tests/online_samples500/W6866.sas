/* New workflow W6866; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6866i;
length gene $80;
gene='p01';raw_p=0.05;output;
gene='p02';raw_p=0.5514419166959844;output;
gene='p03';raw_p=0.8281942073373318;output;
gene='p04';raw_p=0;output;
gene='p05';raw_p=0.27751251805329435;output;
gene='p06';raw_p=0.017436544452403724;output;
gene='p07';raw_p=0.01;output;
gene='p08';raw_p=0.31508908624492105;output;
gene='p09';raw_p=0.478003096860913;output;
gene='p10';raw_p=0.05;output;
gene='p11';raw_p=0.42221968140574295;output;
gene='p12';raw_p=0.19909082948465973;output;
run;
data w6866o;set w6866i;retain adjusted 0;adjusted=max(adjusted,raw_p);run;
data w6866m(keep=metric value);set w6866o;length metric $120;array measured[*] adjusted;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6866m;set w6866m;format value best32.;run;
proc export data=w6866m outfile="%sysfunc(pathname(work))/W6866.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6866;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6866:;quit;
