/* New workflow W6676; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6676i;
length gene $80;
gene='s01';effect=-0.8865096202106448;variance=0.07812468684080356;output;
gene='s02';effect=-0.36951355380491413;variance=0.05627414938080917;output;
gene='s03';effect=0.28960807911661823;variance=0.0698462475388079;output;
gene='s04';effect=-0.1204853323778412;variance=0.025523398505744935;output;
gene='s05';effect=-0.11067049069020096;variance=0.10623118183432048;output;
run;
proc sql;create table w6676o as select "meta" as gene,sum(1/variance) as sw,sum(effect/variance)/calculated sw as beta,sum(effect*effect/variance)-sum(effect/variance)**2/calculated sw as q,count(*)-1 as df from w6676i;quit;data w6676o;set w6676o;i2=max(0,(q-df)/q);run;
data w6676m(keep=metric value);set w6676o;length metric $120;array measured[*] sw beta q df i2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6676m;set w6676m;format value best32.;run;
proc export data=w6676m outfile="%sysfunc(pathname(work))/W6676.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6676;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6676:;quit;
