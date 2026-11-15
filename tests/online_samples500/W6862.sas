/* New workflow W6862; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6862i;
length gene $80;
gene='p01';raw_p=0.001;output;
gene='p02';raw_p=0.4081930870217604;output;
gene='p03';raw_p=0.8348985683705319;output;
gene='p04';raw_p=1;output;
gene='p05';raw_p=0.5616024139341045;output;
gene='p06';raw_p=0.9467108875604415;output;
gene='p07';raw_p=0.8;output;
gene='p08';raw_p=0.39471384428339507;output;
run;
data w6862o;set w6862i;retain adjusted 0;adjusted=max(adjusted,raw_p);run;
data w6862m(keep=metric value);set w6862o;length metric $120;array measured[*] adjusted;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6862m;set w6862m;format value best32.;run;
proc export data=w6862m outfile="%sysfunc(pathname(work))/W6862.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6862;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6862:;quit;
