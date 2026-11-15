/* New workflow W6670; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6670i;
length gene $80;
gene='s01';effect=0.9924923832422607;variance=0.1161916286491761;output;
gene='s02';effect=0.9344402677411443;variance=0.27510360537010936;output;
gene='s03';effect=-0.33122632514055295;variance=0.09356321905857407;output;
gene='s04';effect=-0.9270952771958427;variance=0.09957194344925469;output;
gene='s05';effect=-0.3250582631830805;variance=0.13008376032844146;output;
gene='s06';effect=0.9326042203718279;variance=0.2719825462597925;output;
run;
proc sql;create table w6670o as select "meta" as gene,sum(1/variance) as sw,sum(effect/variance)/calculated sw as beta,sum(effect*effect/variance)-sum(effect/variance)**2/calculated sw as q,count(*)-1 as df from w6670i;quit;data w6670o;set w6670o;i2=max(0,(q-df)/q);run;
data w6670m(keep=metric value);set w6670o;length metric $120;array measured[*] sw beta q df i2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6670m;set w6670m;format value best32.;run;
proc export data=w6670m outfile="%sysfunc(pathname(work))/W6670.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6670;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6670:;quit;
