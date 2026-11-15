/* New workflow W6718; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6718i;
length gene $80;
gene='p01';raw_p=0.01;output;
gene='p02';raw_p=0.3775696249337306;output;
gene='p03';raw_p=0.9509683251323973;output;
gene='p04';raw_p=0.01;output;
gene='p05';raw_p=0.22285276901786089;output;
gene='p06';raw_p=0.76295871641322;output;
gene='p07';raw_p=0.001;output;
gene='p08';raw_p=0.6369191353343996;output;
gene='p09';raw_p=0.6285587353560623;output;
gene='p10';raw_p=0.01;output;
run;
data w6718o;set w6718i;bon_p=min(1,10*raw_p);sid_p=1-(1-raw_p)**10;run;
data w6718m(keep=metric value);set w6718o;length metric $120;array measured[*] bon_p sid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6718m;set w6718m;format value best32.;run;
proc export data=w6718m outfile="%sysfunc(pathname(work))/W6718.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6718;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6718:;quit;
