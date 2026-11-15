/* New workflow W6739; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6739i;
length gene $80;
gene='p01';raw_p=0;output;
gene='p02';raw_p=0.0014108584526740797;output;
gene='p03';raw_p=0.9526829654486747;output;
gene='p04';raw_p=1e-05;output;
gene='p05';raw_p=0.47612950341801086;output;
gene='p06';raw_p=0.9913701184158402;output;
gene='p07';raw_p=0.05;output;
gene='p08';raw_p=0.2999003117499838;output;
gene='p09';raw_p=0.19065117537202914;output;
gene='p10';raw_p=1;output;
gene='p11';raw_p=0.7951268634920678;output;
run;
proc multtest inpvalues=w6739i bon out=w6739o noprint;run;
data w6739m(keep=metric value);set w6739o;length metric $120;array measured[*] bon_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6739m;set w6739m;format value best32.;run;
proc export data=w6739m outfile="%sysfunc(pathname(work))/W6739.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6739;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6739:;quit;
