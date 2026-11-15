/* New workflow W6895; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6895i;
p=0.32179298181449995;output;
p=0.8411738974043518;output;
p=0.6923058327026881;output;
p=0.5950836914760675;output;
run;
proc sql;create table w6895o as select "combined" as gene,-2*sum(log(p)) as statistic,2*count(*) as df from w6895i;quit;data w6895o;set w6895o;p=1-probchi(statistic,df);run;
data w6895m(keep=metric value);set w6895o;length metric $120;array measured[*] statistic df p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6895m;set w6895m;format value best32.;run;
proc export data=w6895m outfile="%sysfunc(pathname(work))/W6895.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6895;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6895:;quit;
