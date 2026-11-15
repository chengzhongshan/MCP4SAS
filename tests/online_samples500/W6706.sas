/* New workflow W6706; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6706i;
length gene $80;
gene='p01';raw_p=0;output;
gene='p02';raw_p=0.856441770113025;output;
gene='p03';raw_p=0.5509572238424618;output;
gene='p04';raw_p=1;output;
gene='p05';raw_p=0.07379555993107578;output;
gene='p06';raw_p=0.7402820181221549;output;
gene='p07';raw_p=1;output;
gene='p08';raw_p=0.09456768997879517;output;
gene='p09';raw_p=0.8461963036596731;output;
gene='p10';raw_p=0.005;output;
gene='p11';raw_p=0.39370544364797055;output;
gene='p12';raw_p=0.5779294405458003;output;
run;
data w6706o;set w6706i;bon_p=min(1,12*raw_p);sid_p=1-(1-raw_p)**12;run;
data w6706m(keep=metric value);set w6706o;length metric $120;array measured[*] bon_p sid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6706m;set w6706m;format value best32.;run;
proc export data=w6706m outfile="%sysfunc(pathname(work))/W6706.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6706;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6706:;quit;
