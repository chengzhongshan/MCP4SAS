/* New workflow W6662; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6662i;
length gene $80;
gene='s01';effect=0.2735303882209199;variance=0.030902331571677724;output;
gene='s02';effect=0.6571543121172654;variance=0.11700617588534809;output;
gene='s03';effect=-0.027813640598759015;variance=0.12632396039365107;output;
gene='s04';effect=0.9509115381226703;variance=0.07454873266996911;output;
gene='s05';effect=0.08447244133069343;variance=0.07523953476073385;output;
run;
proc sql;create table w6662o as select "meta" as gene,sum(1/variance) as sw,sum(effect/variance)/calculated sw as beta,sum(effect*effect/variance)-sum(effect/variance)**2/calculated sw as q,count(*)-1 as df from w6662i;quit;data w6662o;set w6662o;i2=max(0,(q-df)/q);run;
data w6662m(keep=metric value);set w6662o;length metric $120;array measured[*] sw beta q df i2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6662m;set w6662m;format value best32.;run;
proc export data=w6662m outfile="%sysfunc(pathname(work))/W6662.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6662;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6662:;quit;
