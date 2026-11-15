/* New workflow W6917; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6917i;
length gene $80;
gene='s01';effect=0.41391622027528086;variance=0.16476357754296986;output;
gene='s02';effect=-0.9976295711051397;variance=0.034398205375695864;output;
gene='s03';effect=0.37718247177165254;variance=0.2006069160526019;output;
gene='s04';effect=0.21917562157557424;variance=0.2367353908141185;output;
gene='s05';effect=-0.1550016948990076;variance=0.09492121071833581;output;
gene='s06';effect=-0.9687091568603314;variance=0.11311873911137851;output;
run;
proc sql;create table w6917o as select a.gene,sum(b.effect/b.variance)/sum(1/b.variance) as beta,1/sum(1/b.variance) as variance from w6917i as a,w6917i as b where a.gene ne b.gene group by a.gene;quit;
data w6917m(keep=metric value);set w6917o;length metric $120;array measured[*] beta variance;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6917m;set w6917m;format value best32.;run;
proc export data=w6917m outfile="%sysfunc(pathname(work))/W6917.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6917;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6917:;quit;
