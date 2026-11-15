/* New workflow W6819; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6819i;
length gene $80;
gene='p01';raw_p=0.8;output;
gene='p02';raw_p=0.08306402812166602;output;
gene='p03';raw_p=0.917811282689171;output;
gene='p04';raw_p=1e-05;output;
gene='p05';raw_p=0.0005081481238563557;output;
gene='p06';raw_p=0.16116875331623992;output;
gene='p07';raw_p=0;output;
gene='p08';raw_p=0.05263481398616021;output;
gene='p09';raw_p=0.7981515965050118;output;
gene='p10';raw_p=0.8;output;
gene='p11';raw_p=0.6588663203981904;output;
run;
proc multtest inpvalues=w6819i hoc out=w6819o noprint;run;
data w6819m(keep=metric value);set w6819o;length metric $120;array measured[*] hoc_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6819m;set w6819m;format value best32.;run;
proc export data=w6819m outfile="%sysfunc(pathname(work))/W6819.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6819;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6819:;quit;
