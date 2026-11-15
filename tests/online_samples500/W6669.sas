/* New workflow W6669; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6669i;
length gene $80;
gene='s01';effect=-0.06616298025676559;variance=0.06056589533758344;output;
gene='s02';effect=-0.6643337108693046;variance=0.2531729924935411;output;
gene='s03';effect=-0.9986892518651886;variance=0.04935696543214676;output;
gene='s04';effect=0.7685086355566006;variance=0.27386917370519115;output;
gene='s05';effect=-0.4285756111509349;variance=0.10193580996102801;output;
run;
proc sql;create table w6669o as select "meta" as gene,sum(1/variance) as sw,sum(effect/variance)/calculated sw as beta,sum(effect*effect/variance)-sum(effect/variance)**2/calculated sw as q,count(*)-1 as df from w6669i;quit;data w6669o;set w6669o;i2=max(0,(q-df)/q);run;
data w6669m(keep=metric value);set w6669o;length metric $120;array measured[*] sw beta q df i2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6669m;set w6669m;format value best32.;run;
proc export data=w6669m outfile="%sysfunc(pathname(work))/W6669.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6669;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6669:;quit;
