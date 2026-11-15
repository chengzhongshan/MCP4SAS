/* New workflow W6886; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6886i;
p=0.017928809917882805;output;
p=0.7062685638602291;output;
p=0.3479059142072702;output;
p=0.4334269916750249;output;
p=0.1269571933780352;output;
p=0.04506281520110979;output;
p=0.09855697182179769;output;
p=0.2103357958761149;output;
p=0.2908668846207026;output;
run;
proc sql;create table w6886o as select "combined" as gene,-2*sum(log(p)) as statistic,2*count(*) as df from w6886i;quit;data w6886o;set w6886o;p=1-probchi(statistic,df);run;
data w6886m(keep=metric value);set w6886o;length metric $120;array measured[*] statistic df p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6886m;set w6886m;format value best32.;run;
proc export data=w6886m outfile="%sysfunc(pathname(work))/W6886.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6886;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6886:;quit;
