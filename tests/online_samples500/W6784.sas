/* New workflow W6784; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6784i;
length gene $80;
gene='p01';raw_p=0.05;output;
gene='p02';raw_p=0.22162839440010307;output;
gene='p03';raw_p=0.2455261916523852;output;
gene='p04';raw_p=0.005;output;
gene='p05';raw_p=0.39493557280735725;output;
gene='p06';raw_p=0.0946356620088481;output;
gene='p07';raw_p=0.05;output;
gene='p08';raw_p=0.019985076057339457;output;
gene='p09';raw_p=0.08342019125201672;output;
gene='p10';raw_p=0.8;output;
run;
proc multtest inpvalues=w6784i stepsid out=w6784o noprint;run;
data w6784m(keep=metric value);set w6784o;length metric $120;array measured[*] stpsid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6784m;set w6784m;format value best32.;run;
proc export data=w6784m outfile="%sysfunc(pathname(work))/W6784.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6784;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6784:;quit;
