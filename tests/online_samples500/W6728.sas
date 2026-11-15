/* New workflow W6728; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6728i;
length gene $80;
gene='p01';raw_p=0.2;output;
gene='p02';raw_p=0.5582548752299227;output;
gene='p03';raw_p=0.8429838234446464;output;
gene='p04';raw_p=0.001;output;
gene='p05';raw_p=0.6766512050697524;output;
gene='p06';raw_p=0.33290864914331886;output;
gene='p07';raw_p=0;output;
run;
proc multtest inpvalues=w6728i bon out=w6728o noprint;run;
data w6728m(keep=metric value);set w6728o;length metric $120;array measured[*] bon_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6728m;set w6728m;format value best32.;run;
proc export data=w6728m outfile="%sysfunc(pathname(work))/W6728.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6728;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6728:;quit;
