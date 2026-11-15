/* New workflow W6861; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6861i;
length gene $80;
gene='p01';raw_p=1e-05;output;
gene='p02';raw_p=0.5329786708231243;output;
gene='p03';raw_p=0.8516392045614979;output;
gene='p04';raw_p=0.01;output;
gene='p05';raw_p=0.7380858418860154;output;
gene='p06';raw_p=0.08207249777444958;output;
gene='p07';raw_p=0.05;output;
run;
data w6861o;set w6861i;retain adjusted 0;adjusted=max(adjusted,raw_p);run;
data w6861m(keep=metric value);set w6861o;length metric $120;array measured[*] adjusted;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6861m;set w6861m;format value best32.;run;
proc export data=w6861m outfile="%sysfunc(pathname(work))/W6861.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6861;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6861:;quit;
