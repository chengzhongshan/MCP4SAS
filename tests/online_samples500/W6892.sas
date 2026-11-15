/* New workflow W6892; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6892i;
p=0.054318697945061264;output;
p=0.37342612413589854;output;
p=0.6681149422488396;output;
p=0.44976591554496836;output;
p=0.15117925867374593;output;
p=0.7186867065359903;output;
p=0.5750007802712434;output;
p=0.4242457826702874;output;
run;
proc sql;create table w6892o as select "combined" as gene,-2*sum(log(p)) as statistic,2*count(*) as df from w6892i;quit;data w6892o;set w6892o;p=1-probchi(statistic,df);run;
data w6892m(keep=metric value);set w6892o;length metric $120;array measured[*] statistic df p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6892m;set w6892m;format value best32.;run;
proc export data=w6892m outfile="%sysfunc(pathname(work))/W6892.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6892;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6892:;quit;
