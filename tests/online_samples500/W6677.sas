/* New workflow W6677; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6677i;
length gene $80;
gene='s01';effect=0.5784530175491229;variance=0.2506667457902377;output;
gene='s02';effect=-0.1974815800971388;variance=0.08192082256008659;output;
gene='s03';effect=-0.41656836190244184;variance=0.034201482651188886;output;
gene='s04';effect=0.4935026975948804;variance=0.0873911576185755;output;
gene='s05';effect=0.6610904425057684;variance=0.22953143589030764;output;
gene='s06';effect=0.9260639057264135;variance=0.13036495211816915;output;
run;
proc sql;create table w6677o as select "meta" as gene,sum(1/variance) as sw,sum(effect/variance)/calculated sw as beta,sum(effect*effect/variance)-sum(effect/variance)**2/calculated sw as q,count(*)-1 as df from w6677i;quit;data w6677o;set w6677o;i2=max(0,(q-df)/q);run;
data w6677m(keep=metric value);set w6677o;length metric $120;array measured[*] sw beta q df i2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6677m;set w6677m;format value best32.;run;
proc export data=w6677m outfile="%sysfunc(pathname(work))/W6677.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6677;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6677:;quit;
