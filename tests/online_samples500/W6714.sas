/* New workflow W6714; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6714i;
length gene $80;
gene='p01';raw_p=1e-05;output;
gene='p02';raw_p=0.5792009272055739;output;
gene='p03';raw_p=0.78808847537112;output;
gene='p04';raw_p=0.2;output;
gene='p05';raw_p=0.9927014591672187;output;
gene='p06';raw_p=0.7877484565071111;output;
run;
data w6714o;set w6714i;bon_p=min(1,6*raw_p);sid_p=1-(1-raw_p)**6;run;
data w6714m(keep=metric value);set w6714o;length metric $120;array measured[*] bon_p sid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6714m;set w6714m;format value best32.;run;
proc export data=w6714m outfile="%sysfunc(pathname(work))/W6714.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6714;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6714:;quit;
