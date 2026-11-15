/* New workflow W6708; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6708i;
length gene $80;
gene='p01';raw_p=0.05;output;
gene='p02';raw_p=0.467867194038297;output;
gene='p03';raw_p=0.31737464803792803;output;
gene='p04';raw_p=1e-05;output;
gene='p05';raw_p=0.0560088680346601;output;
gene='p06';raw_p=0.4074271386134265;output;
gene='p07';raw_p=1;output;
run;
data w6708o;set w6708i;bon_p=min(1,7*raw_p);sid_p=1-(1-raw_p)**7;run;
data w6708m(keep=metric value);set w6708o;length metric $120;array measured[*] bon_p sid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6708m;set w6708m;format value best32.;run;
proc export data=w6708m outfile="%sysfunc(pathname(work))/W6708.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6708;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6708:;quit;
