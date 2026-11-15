/* New workflow W6896; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6896i;
p=0.27466747235276023;output;
p=0.5876803769546743;output;
p=0.5507741641501046;output;
p=0.8843990956329258;output;
p=0.286181082842506;output;
run;
proc sql;create table w6896o as select "combined" as gene,-2*sum(log(p)) as statistic,2*count(*) as df from w6896i;quit;data w6896o;set w6896o;p=1-probchi(statistic,df);run;
data w6896m(keep=metric value);set w6896o;length metric $120;array measured[*] statistic df p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6896m;set w6896m;format value best32.;run;
proc export data=w6896m outfile="%sysfunc(pathname(work))/W6896.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6896;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6896:;quit;
