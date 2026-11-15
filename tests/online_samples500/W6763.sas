/* New workflow W6763; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6763i;
length gene $80;
gene='p01';raw_p=1;output;
gene='p02';raw_p=0.45310509613020367;output;
gene='p03';raw_p=0.9731012791455543;output;
gene='p04';raw_p=0.001;output;
gene='p05';raw_p=0.7666221785073972;output;
gene='p06';raw_p=0.4600685100042229;output;
gene='p07';raw_p=0.001;output;
gene='p08';raw_p=0.9279563491590511;output;
gene='p09';raw_p=0.7901710322915874;output;
run;
proc multtest inpvalues=w6763i holm out=w6763o noprint;run;
data w6763m(keep=metric value);set w6763o;length metric $120;array measured[*] stpbon_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6763m;set w6763m;format value best32.;run;
proc export data=w6763m outfile="%sysfunc(pathname(work))/W6763.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6763;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6763:;quit;
