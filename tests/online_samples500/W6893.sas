/* New workflow W6893; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6893i;
p=0.09467953583816298;output;
p=0.4720905340074076;output;
p=0.3034489622534463;output;
p=0.14346008170869132;output;
p=0.6327357543997909;output;
p=0.5868220204256029;output;
p=0.29596565184273055;output;
p=0.16776864738272992;output;
p=0.30112828998094365;output;
run;
proc sql;create table w6893o as select "combined" as gene,-2*sum(log(p)) as statistic,2*count(*) as df from w6893i;quit;data w6893o;set w6893o;p=1-probchi(statistic,df);run;
data w6893m(keep=metric value);set w6893o;length metric $120;array measured[*] statistic df p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6893m;set w6893m;format value best32.;run;
proc export data=w6893m outfile="%sysfunc(pathname(work))/W6893.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6893;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6893:;quit;
