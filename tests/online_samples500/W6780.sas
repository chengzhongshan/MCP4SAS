/* New workflow W6780; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6780i;
length gene $80;
gene='p01';raw_p=0;output;
gene='p02';raw_p=0.5609150501868723;output;
gene='p03';raw_p=0.19309723669853907;output;
gene='p04';raw_p=0.005;output;
gene='p05';raw_p=0.011302219069868613;output;
gene='p06';raw_p=0.7085623976482744;output;
gene='p07';raw_p=0.05;output;
gene='p08';raw_p=0.9726518635289796;output;
gene='p09';raw_p=0.3067685612875277;output;
gene='p10';raw_p=0.01;output;
gene='p11';raw_p=0.5714779115555417;output;
gene='p12';raw_p=0.6490968492209177;output;
run;
proc multtest inpvalues=w6780i holm out=w6780o noprint;run;
data w6780m(keep=metric value);set w6780o;length metric $120;array measured[*] stpbon_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6780m;set w6780m;format value best32.;run;
proc export data=w6780m outfile="%sysfunc(pathname(work))/W6780.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6780;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6780:;quit;
