/* New workflow W6868; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6868i;
length gene $80;
gene='p01';raw_p=0.005;output;
gene='p02';raw_p=0.4652423722074088;output;
gene='p03';raw_p=0.6172660129675143;output;
gene='p04';raw_p=0.8;output;
gene='p05';raw_p=0.46497264476636757;output;
gene='p06';raw_p=0.766333684135321;output;
gene='p07';raw_p=0.2;output;
run;
data w6868o;set w6868i;retain adjusted 0;adjusted=max(adjusted,raw_p);run;
data w6868m(keep=metric value);set w6868o;length metric $120;array measured[*] adjusted;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6868m;set w6868m;format value best32.;run;
proc export data=w6868m outfile="%sysfunc(pathname(work))/W6868.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6868;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6868:;quit;
