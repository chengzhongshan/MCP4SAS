/* New workflow W6666; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6666i;
length gene $80;
gene='s01';effect=-0.5828164121146286;variance=0.24624896843698993;output;
gene='s02';effect=-0.3731437810916065;variance=0.24021742007446986;output;
gene='s03';effect=-0.40213808577146026;variance=0.11427303490839094;output;
gene='s04';effect=-0.40207416823561704;variance=0.20400894482118026;output;
gene='s05';effect=0.1227715646670724;variance=0.24430747580459783;output;
gene='s06';effect=-0.6180885652646462;variance=0.12311059550009001;output;
gene='s07';effect=-0.40760492430255235;variance=0.2461397139062232;output;
gene='s08';effect=0.4087051121062022;variance=0.07445481434750399;output;
gene='s09';effect=-0.4725348154624931;variance=0.022124046833807438;output;
run;
proc sql;create table w6666o as select "meta" as gene,sum(1/variance) as sw,sum(effect/variance)/calculated sw as beta,sum(effect*effect/variance)-sum(effect/variance)**2/calculated sw as q,count(*)-1 as df from w6666i;quit;data w6666o;set w6666o;i2=max(0,(q-df)/q);run;
data w6666m(keep=metric value);set w6666o;length metric $120;array measured[*] sw beta q df i2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6666m;set w6666m;format value best32.;run;
proc export data=w6666m outfile="%sysfunc(pathname(work))/W6666.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6666;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6666:;quit;
