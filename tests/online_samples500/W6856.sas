/* New workflow W6856; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6856i;
length gene $80;
gene='p01';raw_p=0.2;output;
gene='p02';raw_p=0.8789391973483035;output;
gene='p03';raw_p=0.3326657018008191;output;
gene='p04';raw_p=1e-05;output;
gene='p05';raw_p=0.6613755605972279;output;
gene='p06';raw_p=0.5526242436171274;output;
gene='p07';raw_p=0.01;output;
gene='p08';raw_p=0.8157828722011758;output;
run;
proc multtest inpvalues=w6856i dependentfdr out=w6856o noprint;run;
data w6856m(keep=metric value);set w6856o;length metric $120;array measured[*] dfdr_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6856m;set w6856m;format value best32.;run;
proc export data=w6856m outfile="%sysfunc(pathname(work))/W6856.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6856;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6856:;quit;
