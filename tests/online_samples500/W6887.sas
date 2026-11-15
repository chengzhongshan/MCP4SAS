/* New workflow W6887; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6887i;
p=0.6466251061281002;output;
p=0.5081060854904371;output;
p=0.7488408868077301;output;
run;
proc sql;create table w6887o as select "combined" as gene,-2*sum(log(p)) as statistic,2*count(*) as df from w6887i;quit;data w6887o;set w6887o;p=1-probchi(statistic,df);run;
data w6887m(keep=metric value);set w6887o;length metric $120;array measured[*] statistic df p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6887m;set w6887m;format value best32.;run;
proc export data=w6887m outfile="%sysfunc(pathname(work))/W6887.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6887;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6887:;quit;
