/* New workflow W6753; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6753i;
length gene $80;
gene='p01';raw_p=0.005;output;
gene='p02';raw_p=0.8047463071342126;output;
gene='p03';raw_p=0.841619322161221;output;
gene='p04';raw_p=0.001;output;
gene='p05';raw_p=0.05989216973692457;output;
gene='p06';raw_p=0.3670761102023973;output;
gene='p07';raw_p=1;output;
gene='p08';raw_p=0.06104906658443776;output;
gene='p09';raw_p=0.6240213763769076;output;
gene='p10';raw_p=0;output;
gene='p11';raw_p=0.9302457453069127;output;
gene='p12';raw_p=0.2664188877016749;output;
run;
proc multtest inpvalues=w6753i sid out=w6753o noprint;run;
data w6753m(keep=metric value);set w6753o;length metric $120;array measured[*] sid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6753m;set w6753m;format value best32.;run;
proc export data=w6753m outfile="%sysfunc(pathname(work))/W6753.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6753;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6753:;quit;
