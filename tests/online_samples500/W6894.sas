/* New workflow W6894; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6894i;
p=0.28108979832295106;output;
p=0.8693923018074479;output;
p=0.7919421476976995;output;
run;
proc sql;create table w6894o as select "combined" as gene,-2*sum(log(p)) as statistic,2*count(*) as df from w6894i;quit;data w6894o;set w6894o;p=1-probchi(statistic,df);run;
data w6894m(keep=metric value);set w6894o;length metric $120;array measured[*] statistic df p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6894m;set w6894m;format value best32.;run;
proc export data=w6894m outfile="%sysfunc(pathname(work))/W6894.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6894;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6894:;quit;
