/* New workflow W6713; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6713i;
length gene $80;
gene='p01';raw_p=1e-05;output;
gene='p02';raw_p=0.5112564049077672;output;
gene='p03';raw_p=0.18278925477817087;output;
gene='p04';raw_p=0;output;
gene='p05';raw_p=0.820690208158986;output;
gene='p06';raw_p=0.4004418967782343;output;
gene='p07';raw_p=1e-05;output;
gene='p08';raw_p=0.4200313679056641;output;
gene='p09';raw_p=0.5606867620676939;output;
gene='p10';raw_p=1;output;
gene='p11';raw_p=0.9517151550766471;output;
gene='p12';raw_p=0.27200782814296987;output;
run;
data w6713o;set w6713i;bon_p=min(1,12*raw_p);sid_p=1-(1-raw_p)**12;run;
data w6713m(keep=metric value);set w6713o;length metric $120;array measured[*] bon_p sid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6713m;set w6713m;format value best32.;run;
proc export data=w6713m outfile="%sysfunc(pathname(work))/W6713.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6713;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6713:;quit;
