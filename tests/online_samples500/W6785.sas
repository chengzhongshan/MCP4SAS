/* New workflow W6785; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6785i;
length gene $80;
gene='p01';raw_p=0.005;output;
gene='p02';raw_p=0.15932507006444818;output;
gene='p03';raw_p=0.963270108404513;output;
gene='p04';raw_p=1;output;
gene='p05';raw_p=0.9860966358481065;output;
gene='p06';raw_p=0.3093391081091349;output;
gene='p07';raw_p=0.005;output;
gene='p08';raw_p=0.5625045605756356;output;
gene='p09';raw_p=0.8097945073910214;output;
gene='p10';raw_p=0.001;output;
gene='p11';raw_p=0.22763411586283178;output;
run;
proc multtest inpvalues=w6785i stepsid out=w6785o noprint;run;
data w6785m(keep=metric value);set w6785o;length metric $120;array measured[*] stpsid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6785m;set w6785m;format value best32.;run;
proc export data=w6785m outfile="%sysfunc(pathname(work))/W6785.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6785;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6785:;quit;
