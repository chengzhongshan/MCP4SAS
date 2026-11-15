/* New workflow W6663; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6663i;
length gene $80;
gene='s01';effect=-0.035864925485894705;variance=0.26630697871276343;output;
gene='s02';effect=-0.3982283338059722;variance=0.042778454387835035;output;
gene='s03';effect=0.32857118818411246;variance=0.11930267276735682;output;
gene='s04';effect=-0.8644261744448214;variance=0.05933845351407083;output;
gene='s05';effect=0.5336175938390846;variance=0.14168218607932873;output;
gene='s06';effect=0.018083249387634837;variance=0.18434576737172614;output;
run;
proc sql;create table w6663o as select "meta" as gene,sum(1/variance) as sw,sum(effect/variance)/calculated sw as beta,sum(effect*effect/variance)-sum(effect/variance)**2/calculated sw as q,count(*)-1 as df from w6663i;quit;data w6663o;set w6663o;i2=max(0,(q-df)/q);run;
data w6663m(keep=metric value);set w6663o;length metric $120;array measured[*] sw beta q df i2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6663m;set w6663m;format value best32.;run;
proc export data=w6663m outfile="%sysfunc(pathname(work))/W6663.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6663;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6663:;quit;
