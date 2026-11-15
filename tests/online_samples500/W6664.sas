/* New workflow W6664; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6664i;
length gene $80;
gene='s01';effect=0.847958744931973;variance=0.09755839800041086;output;
gene='s02';effect=-0.5640262097103148;variance=0.2882074773859066;output;
gene='s03';effect=0.03625159693272684;variance=0.28461262988767655;output;
gene='s04';effect=-0.7678728285706671;variance=0.27906549387404356;output;
gene='s05';effect=-0.02907112341871887;variance=0.06596915223238616;output;
gene='s06';effect=-0.17761287061773556;variance=0.1675609539527767;output;
gene='s07';effect=0.5577877572767611;variance=0.19131550049992538;output;
run;
proc sql;create table w6664o as select "meta" as gene,sum(1/variance) as sw,sum(effect/variance)/calculated sw as beta,sum(effect*effect/variance)-sum(effect/variance)**2/calculated sw as q,count(*)-1 as df from w6664i;quit;data w6664o;set w6664o;i2=max(0,(q-df)/q);run;
data w6664m(keep=metric value);set w6664o;length metric $120;array measured[*] sw beta q df i2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6664m;set w6664m;format value best32.;run;
proc export data=w6664m outfile="%sysfunc(pathname(work))/W6664.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6664;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6664:;quit;
