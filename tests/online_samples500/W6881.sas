/* New workflow W6881; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6881i;
p=0.0867226632180463;output;
p=0.36249070849760057;output;
p=0.3736774465583536;output;
p=0.5927653124855953;output;
run;
proc sql;create table w6881o as select "combined" as gene,-2*sum(log(p)) as statistic,2*count(*) as df from w6881i;quit;data w6881o;set w6881o;p=1-probchi(statistic,df);run;
data w6881m(keep=metric value);set w6881o;length metric $120;array measured[*] statistic df p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6881m;set w6881m;format value best32.;run;
proc export data=w6881m outfile="%sysfunc(pathname(work))/W6881.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6881;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6881:;quit;
