/* New workflow W6874; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6874i;
length gene $80;
gene='p01';raw_p=1;output;
gene='p02';raw_p=0.9355702313999402;output;
gene='p03';raw_p=0.3707357773936534;output;
gene='p04';raw_p=0.8;output;
gene='p05';raw_p=0.6069205662058075;output;
gene='p06';raw_p=0.2655210102442872;output;
run;
data w6874o;set w6874i;retain adjusted 0;adjusted=max(adjusted,raw_p);run;
data w6874m(keep=metric value);set w6874o;length metric $120;array measured[*] adjusted;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6874m;set w6874m;format value best32.;run;
proc export data=w6874m outfile="%sysfunc(pathname(work))/W6874.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6874;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6874:;quit;
