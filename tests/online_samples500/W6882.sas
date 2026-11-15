/* New workflow W6882; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6882i;
p=0.6036119067474496;output;
p=0.3928532045181366;output;
p=0.7065425707946983;output;
p=0.7566811447251781;output;
p=0.8804382778449988;output;
run;
proc sql;create table w6882o as select "combined" as gene,-2*sum(log(p)) as statistic,2*count(*) as df from w6882i;quit;data w6882o;set w6882o;p=1-probchi(statistic,df);run;
data w6882m(keep=metric value);set w6882o;length metric $120;array measured[*] statistic df p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6882m;set w6882m;format value best32.;run;
proc export data=w6882m outfile="%sysfunc(pathname(work))/W6882.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6882;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6882:;quit;
