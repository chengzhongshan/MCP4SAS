/* New workflow W6900; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6900i;
p=0.10909979552719286;output;
p=0.7364958910907324;output;
p=0.14777102409723292;output;
p=0.25934476957071223;output;
p=0.3411065652838922;output;
p=0.7643285894546272;output;
p=0.701765116729954;output;
p=0.2737329073533871;output;
p=0.0015255295320559332;output;
run;
proc sql;create table w6900o as select "combined" as gene,-2*sum(log(p)) as statistic,2*count(*) as df from w6900i;quit;data w6900o;set w6900o;p=1-probchi(statistic,df);run;
data w6900m(keep=metric value);set w6900o;length metric $120;array measured[*] statistic df p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6900m;set w6900m;format value best32.;run;
proc export data=w6900m outfile="%sysfunc(pathname(work))/W6900.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6900;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6900:;quit;
