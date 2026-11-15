/* New workflow W6878; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6878i;
length gene $80;
gene='p01';raw_p=0.01;output;
gene='p02';raw_p=0.13389356870298363;output;
gene='p03';raw_p=0.01332934789386353;output;
gene='p04';raw_p=0.005;output;
gene='p05';raw_p=0.7210568557950534;output;
gene='p06';raw_p=0.5254711899018116;output;
gene='p07';raw_p=0;output;
gene='p08';raw_p=0.3165259718702145;output;
gene='p09';raw_p=0.6996832167549327;output;
gene='p10';raw_p=0.001;output;
run;
data w6878o;set w6878i;retain adjusted 0;adjusted=max(adjusted,raw_p);run;
data w6878m(keep=metric value);set w6878o;length metric $120;array measured[*] adjusted;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6878m;set w6878m;format value best32.;run;
proc export data=w6878m outfile="%sysfunc(pathname(work))/W6878.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6878;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6878:;quit;
