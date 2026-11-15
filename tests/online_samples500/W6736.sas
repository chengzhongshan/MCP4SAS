/* New workflow W6736; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6736i;
length gene $80;
gene='p01';raw_p=0.2;output;
gene='p02';raw_p=0.3372657905900477;output;
gene='p03';raw_p=0.22913803416113177;output;
gene='p04';raw_p=0.2;output;
gene='p05';raw_p=0.9427820447255442;output;
gene='p06';raw_p=0.2688704585720926;output;
gene='p07';raw_p=0.2;output;
gene='p08';raw_p=0.7385259033004217;output;
run;
proc multtest inpvalues=w6736i bon out=w6736o noprint;run;
data w6736m(keep=metric value);set w6736o;length metric $120;array measured[*] bon_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6736m;set w6736m;format value best32.;run;
proc export data=w6736m outfile="%sysfunc(pathname(work))/W6736.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6736;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6736:;quit;
