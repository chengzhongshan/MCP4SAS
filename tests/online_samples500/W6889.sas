/* New workflow W6889; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6889i;
p=0.8905384695365454;output;
p=0.7694277734674373;output;
p=0.30664732158526004;output;
p=0.042087601653685636;output;
p=0.5756804415968267;output;
run;
proc sql;create table w6889o as select "combined" as gene,-2*sum(log(p)) as statistic,2*count(*) as df from w6889i;quit;data w6889o;set w6889o;p=1-probchi(statistic,df);run;
data w6889m(keep=metric value);set w6889o;length metric $120;array measured[*] statistic df p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6889m;set w6889m;format value best32.;run;
proc export data=w6889m outfile="%sysfunc(pathname(work))/W6889.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6889;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6889:;quit;
