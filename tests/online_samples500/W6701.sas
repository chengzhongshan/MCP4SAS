/* New workflow W6701; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6701i;
length gene $80;
gene='p01';raw_p=0.8;output;
gene='p02';raw_p=0.5958112088533289;output;
gene='p03';raw_p=0.14903444561326418;output;
gene='p04';raw_p=0.05;output;
gene='p05';raw_p=0.9312194906221121;output;
gene='p06';raw_p=0.4533778579987823;output;
gene='p07';raw_p=0.001;output;
run;
data w6701o;set w6701i;bon_p=min(1,7*raw_p);sid_p=1-(1-raw_p)**7;run;
data w6701m(keep=metric value);set w6701o;length metric $120;array measured[*] bon_p sid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6701m;set w6701m;format value best32.;run;
proc export data=w6701m outfile="%sysfunc(pathname(work))/W6701.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6701;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6701:;quit;
