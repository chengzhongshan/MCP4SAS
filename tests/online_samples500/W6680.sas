/* New workflow W6680; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6680i;
length gene $80;
gene='s01';effect=-0.4727763716413502;variance=0.22960329752604397;output;
gene='s02';effect=-0.9173932905507423;variance=0.045869370974678775;output;
gene='s03';effect=0.6590017502210836;variance=0.2168578442654395;output;
gene='s04';effect=0.6726261987419102;variance=0.1300813154366928;output;
gene='s05';effect=0.9533742916610006;variance=0.12448246859884908;output;
gene='s06';effect=-0.3214111316111974;variance=0.2176207612436436;output;
gene='s07';effect=-0.5695364638273863;variance=0.06292677387722485;output;
gene='s08';effect=0.49259420650917285;variance=0.09807445927294453;output;
gene='s09';effect=-0.8098454920881684;variance=0.12461937837559707;output;
run;
proc sql;create table w6680o as select "meta" as gene,sum(1/variance) as sw,sum(effect/variance)/calculated sw as beta,sum(effect*effect/variance)-sum(effect/variance)**2/calculated sw as q,count(*)-1 as df from w6680i;quit;data w6680o;set w6680o;i2=max(0,(q-df)/q);run;
data w6680m(keep=metric value);set w6680o;length metric $120;array measured[*] sw beta q df i2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6680m;set w6680m;format value best32.;run;
proc export data=w6680m outfile="%sysfunc(pathname(work))/W6680.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6680;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6680:;quit;
