/* New workflow W6885; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6885i;
p=0.3349208606961898;output;
p=0.4814551083225166;output;
p=0.10043791818214531;output;
p=0.5203024414195595;output;
p=0.009454698360484824;output;
p=0.44644536707975113;output;
p=0.214602982907629;output;
p=0.17907870564585313;output;
run;
proc sql;create table w6885o as select "combined" as gene,-2*sum(log(p)) as statistic,2*count(*) as df from w6885i;quit;data w6885o;set w6885o;p=1-probchi(statistic,df);run;
data w6885m(keep=metric value);set w6885o;length metric $120;array measured[*] statistic df p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6885m;set w6885m;format value best32.;run;
proc export data=w6885m outfile="%sysfunc(pathname(work))/W6885.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6885;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6885:;quit;
