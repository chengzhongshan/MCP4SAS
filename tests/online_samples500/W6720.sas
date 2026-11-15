/* New workflow W6720; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6720i;
length gene $80;
gene='p01';raw_p=0.001;output;
gene='p02';raw_p=0.6128913308831023;output;
gene='p03';raw_p=0.5268550911466219;output;
gene='p04';raw_p=0;output;
gene='p05';raw_p=0.5432037713929334;output;
gene='p06';raw_p=0.8712482942071323;output;
gene='p07';raw_p=0.05;output;
gene='p08';raw_p=0.5564885183775248;output;
gene='p09';raw_p=0.6757500732111719;output;
gene='p10';raw_p=0.8;output;
gene='p11';raw_p=0.2788759950686256;output;
gene='p12';raw_p=0.45362184943701256;output;
run;
data w6720o;set w6720i;bon_p=min(1,12*raw_p);sid_p=1-(1-raw_p)**12;run;
data w6720m(keep=metric value);set w6720o;length metric $120;array measured[*] bon_p sid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6720m;set w6720m;format value best32.;run;
proc export data=w6720m outfile="%sysfunc(pathname(work))/W6720.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6720;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6720:;quit;
