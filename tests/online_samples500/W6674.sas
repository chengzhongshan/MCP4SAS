/* New workflow W6674; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6674i;
length gene $80;
gene='s01';effect=-0.889966966162145;variance=0.038038032970981434;output;
gene='s02';effect=0.7640700294380431;variance=0.15209406792241248;output;
gene='s03';effect=0.32044965129421454;variance=0.26337322333646807;output;
run;
proc sql;create table w6674o as select "meta" as gene,sum(1/variance) as sw,sum(effect/variance)/calculated sw as beta,sum(effect*effect/variance)-sum(effect/variance)**2/calculated sw as q,count(*)-1 as df from w6674i;quit;data w6674o;set w6674o;i2=max(0,(q-df)/q);run;
data w6674m(keep=metric value);set w6674o;length metric $120;array measured[*] sw beta q df i2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6674m;set w6674m;format value best32.;run;
proc export data=w6674m outfile="%sysfunc(pathname(work))/W6674.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6674;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6674:;quit;
