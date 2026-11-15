/* New workflow W6800; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6800i;
length gene $80;
gene='p01';raw_p=0.05;output;
gene='p02';raw_p=0.12983319565794416;output;
gene='p03';raw_p=0.6968034441999771;output;
gene='p04';raw_p=0;output;
gene='p05';raw_p=0.7566677061137073;output;
gene='p06';raw_p=0.5303163188134479;output;
gene='p07';raw_p=0.01;output;
gene='p08';raw_p=0.2453270664789896;output;
gene='p09';raw_p=0.6439722127894345;output;
gene='p10';raw_p=0.2;output;
gene='p11';raw_p=0.8827094183056142;output;
gene='p12';raw_p=0.7602279902702359;output;
run;
proc multtest inpvalues=w6800i stepsid out=w6800o noprint;run;
data w6800m(keep=metric value);set w6800o;length metric $120;array measured[*] stpsid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6800m;set w6800m;format value best32.;run;
proc export data=w6800m outfile="%sysfunc(pathname(work))/W6800.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6800;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6800:;quit;
