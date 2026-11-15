/* New workflow W6816; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6816i;
length gene $80;
gene='p01';raw_p=0.001;output;
gene='p02';raw_p=0.7466917322969824;output;
gene='p03';raw_p=0.011389911719640766;output;
gene='p04';raw_p=1e-05;output;
gene='p05';raw_p=0.7057807940689734;output;
gene='p06';raw_p=0.3245110883370339;output;
gene='p07';raw_p=0.8;output;
gene='p08';raw_p=0.7358628314618311;output;
run;
proc multtest inpvalues=w6816i hoc out=w6816o noprint;run;
data w6816m(keep=metric value);set w6816o;length metric $120;array measured[*] hoc_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6816m;set w6816m;format value best32.;run;
proc export data=w6816m outfile="%sysfunc(pathname(work))/W6816.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6816;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6816:;quit;
