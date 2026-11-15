/* New workflow W6770; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6770i;
length gene $80;
gene='p01';raw_p=0.8;output;
gene='p02';raw_p=0.5103235239651073;output;
gene='p03';raw_p=0.6029845972961215;output;
gene='p04';raw_p=1e-05;output;
gene='p05';raw_p=0.7649327564466143;output;
gene='p06';raw_p=0.3788402335981831;output;
gene='p07';raw_p=0.001;output;
gene='p08';raw_p=0.09236762637037688;output;
gene='p09';raw_p=0.6135101978775139;output;
run;
proc multtest inpvalues=w6770i holm out=w6770o noprint;run;
data w6770m(keep=metric value);set w6770o;length metric $120;array measured[*] stpbon_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6770m;set w6770m;format value best32.;run;
proc export data=w6770m outfile="%sysfunc(pathname(work))/W6770.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6770;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6770:;quit;
