/* New workflow W6671; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6671i;
length gene $80;
gene='s01';effect=0.2513969185814149;variance=0.25863223734472907;output;
gene='s02';effect=-0.6425956859710014;variance=0.20558054867436773;output;
gene='s03';effect=0.6042332439127251;variance=0.2640285537796972;output;
gene='s04';effect=-0.8577329349070488;variance=0.11181624950826641;output;
gene='s05';effect=-0.8553933026935308;variance=0.1097692012403671;output;
gene='s06';effect=0.9182427065314611;variance=0.09547798963852518;output;
gene='s07';effect=-0.5556158845445462;variance=0.07360641695524023;output;
run;
proc sql;create table w6671o as select "meta" as gene,sum(1/variance) as sw,sum(effect/variance)/calculated sw as beta,sum(effect*effect/variance)-sum(effect/variance)**2/calculated sw as q,count(*)-1 as df from w6671i;quit;data w6671o;set w6671o;i2=max(0,(q-df)/q);run;
data w6671m(keep=metric value);set w6671o;length metric $120;array measured[*] sw beta q df i2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6671m;set w6671m;format value best32.;run;
proc export data=w6671m outfile="%sysfunc(pathname(work))/W6671.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6671;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6671:;quit;
