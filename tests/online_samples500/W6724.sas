/* New workflow W6724; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6724i;
length gene $80;
gene='p01';raw_p=0.001;output;
gene='p02';raw_p=0.770151007007098;output;
gene='p03';raw_p=0.09536364305854117;output;
gene='p04';raw_p=0.005;output;
gene='p05';raw_p=0.5013320150894808;output;
gene='p06';raw_p=0.7425960776863609;output;
gene='p07';raw_p=1e-05;output;
gene='p08';raw_p=0.2056095938721435;output;
gene='p09';raw_p=0.21782921276300926;output;
gene='p10';raw_p=1;output;
run;
proc multtest inpvalues=w6724i bon out=w6724o noprint;run;
data w6724m(keep=metric value);set w6724o;length metric $120;array measured[*] bon_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6724m;set w6724m;format value best32.;run;
proc export data=w6724m outfile="%sysfunc(pathname(work))/W6724.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6724;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6724:;quit;
