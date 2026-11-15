/* New workflow W6721; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6721i;
length gene $80;
gene='p01';raw_p=1e-05;output;
gene='p02';raw_p=0.2286037146560146;output;
gene='p03';raw_p=0.39317389674971637;output;
gene='p04';raw_p=0.01;output;
gene='p05';raw_p=0.05506450516189476;output;
gene='p06';raw_p=0.14470821672027534;output;
gene='p07';raw_p=0.8;output;
run;
proc multtest inpvalues=w6721i bon out=w6721o noprint;run;
data w6721m(keep=metric value);set w6721o;length metric $120;array measured[*] bon_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6721m;set w6721m;format value best32.;run;
proc export data=w6721m outfile="%sysfunc(pathname(work))/W6721.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6721;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6721:;quit;
