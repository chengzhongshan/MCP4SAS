/* New workflow W6766; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6766i;
length gene $80;
gene='p01';raw_p=1e-05;output;
gene='p02';raw_p=0.6667918487276182;output;
gene='p03';raw_p=0.6830787355470613;output;
gene='p04';raw_p=0.01;output;
gene='p05';raw_p=0.6077085203874837;output;
gene='p06';raw_p=0.00024510543778299976;output;
gene='p07';raw_p=0.2;output;
gene='p08';raw_p=0.13279968364122197;output;
gene='p09';raw_p=0.35791132818880766;output;
gene='p10';raw_p=0.001;output;
gene='p11';raw_p=0.9418972688832002;output;
gene='p12';raw_p=0.04142133632726541;output;
run;
proc multtest inpvalues=w6766i holm out=w6766o noprint;run;
data w6766m(keep=metric value);set w6766o;length metric $120;array measured[*] stpbon_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6766m;set w6766m;format value best32.;run;
proc export data=w6766m outfile="%sysfunc(pathname(work))/W6766.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6766;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6766:;quit;
