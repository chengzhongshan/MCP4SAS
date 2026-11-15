/* New workflow W6890; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6890i;
p=0.0005199281138418108;output;
p=0.5813243700312432;output;
p=0.31798748083704537;output;
p=0.09854955891000051;output;
p=0.23288053947532794;output;
p=0.7440450955924915;output;
run;
proc sql;create table w6890o as select "combined" as gene,-2*sum(log(p)) as statistic,2*count(*) as df from w6890i;quit;data w6890o;set w6890o;p=1-probchi(statistic,df);run;
data w6890m(keep=metric value);set w6890o;length metric $120;array measured[*] statistic df p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6890m;set w6890m;format value best32.;run;
proc export data=w6890m outfile="%sysfunc(pathname(work))/W6890.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6890;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6890:;quit;
