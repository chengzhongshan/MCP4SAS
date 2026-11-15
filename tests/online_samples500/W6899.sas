/* New workflow W6899; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6899i;
p=0.37638913454685874;output;
p=0.8073687580857185;output;
p=0.5396285318713291;output;
p=0.45843042511975196;output;
p=0.04042064502393265;output;
p=0.8033642608420575;output;
p=0.7913642066347487;output;
p=0.7318815149599552;output;
run;
proc sql;create table w6899o as select "combined" as gene,-2*sum(log(p)) as statistic,2*count(*) as df from w6899i;quit;data w6899o;set w6899o;p=1-probchi(statistic,df);run;
data w6899m(keep=metric value);set w6899o;length metric $120;array measured[*] statistic df p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6899m;set w6899m;format value best32.;run;
proc export data=w6899m outfile="%sysfunc(pathname(work))/W6899.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6899;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6899:;quit;
