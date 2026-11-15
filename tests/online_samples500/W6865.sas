/* New workflow W6865; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6865i;
length gene $80;
gene='p01';raw_p=0.005;output;
gene='p02';raw_p=0.28755997783200515;output;
gene='p03';raw_p=0.5084176497673277;output;
gene='p04';raw_p=0.001;output;
gene='p05';raw_p=0.8138964879402876;output;
gene='p06';raw_p=0.795493193936068;output;
gene='p07';raw_p=1;output;
gene='p08';raw_p=0.7551455474491794;output;
gene='p09';raw_p=0.38199876905189734;output;
gene='p10';raw_p=0.005;output;
gene='p11';raw_p=0.24668950047585447;output;
run;
data w6865o;set w6865i;retain adjusted 0;adjusted=max(adjusted,raw_p);run;
data w6865m(keep=metric value);set w6865o;length metric $120;array measured[*] adjusted;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6865m;set w6865m;format value best32.;run;
proc export data=w6865m outfile="%sysfunc(pathname(work))/W6865.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6865;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6865:;quit;
