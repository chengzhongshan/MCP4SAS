/* New workflow W6665; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6665i;
length gene $80;
gene='s01';effect=0.6217522958375181;variance=0.25767531402506794;output;
gene='s02';effect=-0.6342283060463243;variance=0.20467987032896842;output;
gene='s03';effect=-0.41801428625393977;variance=0.18460464773648994;output;
gene='s04';effect=-0.9377578594760811;variance=0.29377996721914945;output;
gene='s05';effect=-0.3446974618738161;variance=0.10432683853434203;output;
gene='s06';effect=0.4175707797895267;variance=0.22514175426989433;output;
gene='s07';effect=0.1599938634590985;variance=0.1004821876161732;output;
gene='s08';effect=-0.17885019132257107;variance=0.19424709058462078;output;
run;
proc sql;create table w6665o as select "meta" as gene,sum(1/variance) as sw,sum(effect/variance)/calculated sw as beta,sum(effect*effect/variance)-sum(effect/variance)**2/calculated sw as q,count(*)-1 as df from w6665i;quit;data w6665o;set w6665o;i2=max(0,(q-df)/q);run;
data w6665m(keep=metric value);set w6665o;length metric $120;array measured[*] sw beta q df i2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6665m;set w6665m;format value best32.;run;
proc export data=w6665m outfile="%sysfunc(pathname(work))/W6665.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6665;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6665:;quit;
