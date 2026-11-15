/* New workflow W6897; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6897i;
p=0.0734486298887447;output;
p=0.5930214512119648;output;
p=0.5413637909853884;output;
p=0.18723078685237785;output;
p=0.5048422400619459;output;
p=0.5782420331952406;output;
run;
proc sql;create table w6897o as select "combined" as gene,-2*sum(log(p)) as statistic,2*count(*) as df from w6897i;quit;data w6897o;set w6897o;p=1-probchi(statistic,df);run;
data w6897m(keep=metric value);set w6897o;length metric $120;array measured[*] statistic df p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6897m;set w6897m;format value best32.;run;
proc export data=w6897m outfile="%sysfunc(pathname(work))/W6897.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6897;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6897:;quit;
