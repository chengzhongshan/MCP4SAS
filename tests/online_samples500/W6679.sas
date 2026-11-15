/* New workflow W6679; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6679i;
length gene $80;
gene='s01';effect=0.021572300251160526;variance=0.2859438849511853;output;
gene='s02';effect=-0.02155795820195361;variance=0.20525893177536464;output;
gene='s03';effect=-0.915719444863001;variance=0.09410872011387039;output;
gene='s04';effect=0.5467485459704162;variance=0.1960493762986452;output;
gene='s05';effect=-0.011448428348478368;variance=0.08594406298638535;output;
gene='s06';effect=-0.49872134103609;variance=0.05902604703404046;output;
gene='s07';effect=0.3453758518691712;variance=0.11683052073153716;output;
gene='s08';effect=-0.5244045689318986;variance=0.07912631492422666;output;
run;
proc sql;create table w6679o as select "meta" as gene,sum(1/variance) as sw,sum(effect/variance)/calculated sw as beta,sum(effect*effect/variance)-sum(effect/variance)**2/calculated sw as q,count(*)-1 as df from w6679i;quit;data w6679o;set w6679o;i2=max(0,(q-df)/q);run;
data w6679m(keep=metric value);set w6679o;length metric $120;array measured[*] sw beta q df i2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6679m;set w6679m;format value best32.;run;
proc export data=w6679m outfile="%sysfunc(pathname(work))/W6679.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6679;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6679:;quit;
