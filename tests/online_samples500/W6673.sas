/* New workflow W6673; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6673i;
length gene $80;
gene='s01';effect=-0.5222081227849347;variance=0.08778894834600481;output;
gene='s02';effect=-0.9130940112133081;variance=0.10916896139189101;output;
gene='s03';effect=0.3305880646426238;variance=0.25316172684562294;output;
gene='s04';effect=-0.5218063902399073;variance=0.11004641380495882;output;
gene='s05';effect=0.9402689626711072;variance=0.10165734041081481;output;
gene='s06';effect=0.9827734718693355;variance=0.09544853879752156;output;
gene='s07';effect=-0.7805306706659039;variance=0.18712988230112815;output;
gene='s08';effect=0.5585851765756749;variance=0.26612547369818146;output;
gene='s09';effect=0.9795562234454518;variance=0.2723921086016039;output;
run;
proc sql;create table w6673o as select "meta" as gene,sum(1/variance) as sw,sum(effect/variance)/calculated sw as beta,sum(effect*effect/variance)-sum(effect/variance)**2/calculated sw as q,count(*)-1 as df from w6673i;quit;data w6673o;set w6673o;i2=max(0,(q-df)/q);run;
data w6673m(keep=metric value);set w6673o;length metric $120;array measured[*] sw beta q df i2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6673m;set w6673m;format value best32.;run;
proc export data=w6673m outfile="%sysfunc(pathname(work))/W6673.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6673;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6673:;quit;
