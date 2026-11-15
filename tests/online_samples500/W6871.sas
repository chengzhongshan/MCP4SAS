/* New workflow W6871; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6871i;
length gene $80;
gene='p01';raw_p=0.005;output;
gene='p02';raw_p=0.4077455362215585;output;
gene='p03';raw_p=0.26572512090032163;output;
gene='p04';raw_p=0.001;output;
gene='p05';raw_p=0.6292925538211459;output;
gene='p06';raw_p=0.13127402909504915;output;
gene='p07';raw_p=0;output;
gene='p08';raw_p=0.7849946826212805;output;
gene='p09';raw_p=0.31116698494752726;output;
gene='p10';raw_p=0.2;output;
run;
data w6871o;set w6871i;retain adjusted 0;adjusted=max(adjusted,raw_p);run;
data w6871m(keep=metric value);set w6871o;length metric $120;array measured[*] adjusted;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6871m;set w6871m;format value best32.;run;
proc export data=w6871m outfile="%sysfunc(pathname(work))/W6871.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6871;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6871:;quit;
