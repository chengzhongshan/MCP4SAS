/* New workflow W6678; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6678i;
length gene $80;
gene='s01';effect=0.6340191076860788;variance=0.02548685683884568;output;
gene='s02';effect=-0.18594489991948882;variance=0.1253960569621887;output;
gene='s03';effect=-0.24195832599946132;variance=0.21515509973904925;output;
gene='s04';effect=0.6409204220654705;variance=0.1293319008144128;output;
gene='s05';effect=-0.9661106206877241;variance=0.18813660238110583;output;
gene='s06';effect=-0.5555340025348685;variance=0.21959916537495572;output;
gene='s07';effect=-0.021651633822059813;variance=0.09183737300449418;output;
run;
proc sql;create table w6678o as select "meta" as gene,sum(1/variance) as sw,sum(effect/variance)/calculated sw as beta,sum(effect*effect/variance)-sum(effect/variance)**2/calculated sw as q,count(*)-1 as df from w6678i;quit;data w6678o;set w6678o;i2=max(0,(q-df)/q);run;
data w6678m(keep=metric value);set w6678o;length metric $120;array measured[*] sw beta q df i2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6678m;set w6678m;format value best32.;run;
proc export data=w6678m outfile="%sysfunc(pathname(work))/W6678.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6678;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6678:;quit;
