/* New workflow W6837; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6837i;
length gene $80;
gene='p01';raw_p=0.2;output;
gene='p02';raw_p=0.012708026473298939;output;
gene='p03';raw_p=0.7080359254418076;output;
gene='p04';raw_p=1;output;
gene='p05';raw_p=0.6752112190808343;output;
gene='p06';raw_p=0.29495373898089117;output;
gene='p07';raw_p=0.001;output;
gene='p08';raw_p=0.32490924566718105;output;
gene='p09';raw_p=0.5350770589402627;output;
run;
proc multtest inpvalues=w6837i fdr out=w6837o noprint;run;
data w6837m(keep=metric value);set w6837o;length metric $120;array measured[*] fdr_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6837m;set w6837m;format value best32.;run;
proc export data=w6837m outfile="%sysfunc(pathname(work))/W6837.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6837;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6837:;quit;
