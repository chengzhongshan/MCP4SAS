/* New workflow W6807; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6807i;
length gene $80;
gene='p01';raw_p=1;output;
gene='p02';raw_p=0.9691751338147503;output;
gene='p03';raw_p=0.764691129668976;output;
gene='p04';raw_p=1e-05;output;
gene='p05';raw_p=0.996641579296853;output;
gene='p06';raw_p=0.43347970015635273;output;
run;
proc multtest inpvalues=w6807i hoc out=w6807o noprint;run;
data w6807m(keep=metric value);set w6807o;length metric $120;array measured[*] hoc_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6807m;set w6807m;format value best32.;run;
proc export data=w6807m outfile="%sysfunc(pathname(work))/W6807.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6807;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6807:;quit;
