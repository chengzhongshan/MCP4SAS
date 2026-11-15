/* New workflow W6888; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6888i;
p=0.3145019001085591;output;
p=0.8274497487298371;output;
p=0.23629666615818642;output;
p=0.02908738012237497;output;
run;
proc sql;create table w6888o as select "combined" as gene,-2*sum(log(p)) as statistic,2*count(*) as df from w6888i;quit;data w6888o;set w6888o;p=1-probchi(statistic,df);run;
data w6888m(keep=metric value);set w6888o;length metric $120;array measured[*] statistic df p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6888m;set w6888m;format value best32.;run;
proc export data=w6888m outfile="%sysfunc(pathname(work))/W6888.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6888;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6888:;quit;
