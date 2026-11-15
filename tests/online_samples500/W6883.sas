/* New workflow W6883; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6883i;
p=0.043889151424437216;output;
p=0.1766569522582475;output;
p=0.6283206931107147;output;
p=0.14441248188073844;output;
p=0.11439948746165376;output;
p=0.518755922790466;output;
run;
proc sql;create table w6883o as select "combined" as gene,-2*sum(log(p)) as statistic,2*count(*) as df from w6883i;quit;data w6883o;set w6883o;p=1-probchi(statistic,df);run;
data w6883m(keep=metric value);set w6883o;length metric $120;array measured[*] statistic df p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6883m;set w6883m;format value best32.;run;
proc export data=w6883m outfile="%sysfunc(pathname(work))/W6883.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6883;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6883:;quit;
