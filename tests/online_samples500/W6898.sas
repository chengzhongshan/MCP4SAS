/* New workflow W6898; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6898i;
p=0.07290766753785045;output;
p=0.7377147997232513;output;
p=0.07136537629110985;output;
p=0.20387963836373799;output;
p=0.03962885418243367;output;
p=0.3539285659165578;output;
p=0.7298455166138719;output;
run;
proc sql;create table w6898o as select "combined" as gene,-2*sum(log(p)) as statistic,2*count(*) as df from w6898i;quit;data w6898o;set w6898o;p=1-probchi(statistic,df);run;
data w6898m(keep=metric value);set w6898o;length metric $120;array measured[*] statistic df p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6898m;set w6898m;format value best32.;run;
proc export data=w6898m outfile="%sysfunc(pathname(work))/W6898.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6898;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6898:;quit;
