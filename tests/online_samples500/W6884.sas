/* New workflow W6884; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6884i;
p=0.5217313191471185;output;
p=0.3970822340679051;output;
p=0.3380690934903264;output;
p=0.17210054740794645;output;
p=0.45221125990967037;output;
p=0.8702730742578907;output;
p=0.2405426717480589;output;
run;
proc sql;create table w6884o as select "combined" as gene,-2*sum(log(p)) as statistic,2*count(*) as df from w6884i;quit;data w6884o;set w6884o;p=1-probchi(statistic,df);run;
data w6884m(keep=metric value);set w6884o;length metric $120;array measured[*] statistic df p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6884m;set w6884m;format value best32.;run;
proc export data=w6884m outfile="%sysfunc(pathname(work))/W6884.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6884;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6884:;quit;
