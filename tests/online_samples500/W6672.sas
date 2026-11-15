/* New workflow W6672; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6672i;
length gene $80;
gene='s01';effect=-0.21674565530706325;variance=0.23242910669032055;output;
gene='s02';effect=-0.1032686324588794;variance=0.12652050868623319;output;
gene='s03';effect=-0.9379308655744025;variance=0.17822132469214266;output;
gene='s04';effect=0.8757852114702769;variance=0.22752644791353577;output;
gene='s05';effect=0.34329974542209785;variance=0.18150452716543192;output;
gene='s06';effect=-0.15331751514766045;variance=0.09922501320022623;output;
gene='s07';effect=-0.25483526899500286;variance=0.1730787547501963;output;
gene='s08';effect=0.6194557437156847;variance=0.21238099893772897;output;
run;
proc sql;create table w6672o as select "meta" as gene,sum(1/variance) as sw,sum(effect/variance)/calculated sw as beta,sum(effect*effect/variance)-sum(effect/variance)**2/calculated sw as q,count(*)-1 as df from w6672i;quit;data w6672o;set w6672o;i2=max(0,(q-df)/q);run;
data w6672m(keep=metric value);set w6672o;length metric $120;array measured[*] sw beta q df i2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6672m;set w6672m;format value best32.;run;
proc export data=w6672m outfile="%sysfunc(pathname(work))/W6672.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6672;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6672:;quit;
