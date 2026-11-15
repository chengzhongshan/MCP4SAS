/* New workflow W6912; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6912i;
length gene $80;
gene='s01';effect=0.4657198680596206;variance=0.26054830887405006;output;
gene='s02';effect=-0.3559254659501758;variance=0.021237090412962668;output;
gene='s03';effect=-0.372041535384678;variance=0.28673016442809773;output;
gene='s04';effect=-0.1649447374975228;variance=0.25041051354114485;output;
gene='s05';effect=-0.8499196128961375;variance=0.25284765349451876;output;
gene='s06';effect=-0.650108719912285;variance=0.23516654394536085;output;
gene='s07';effect=-0.9621046922868526;variance=0.16759875358013887;output;
gene='s08';effect=-0.3364198614195586;variance=0.021181900200793295;output;
run;
proc sql;create table w6912o as select a.gene,sum(b.effect/b.variance)/sum(1/b.variance) as beta,1/sum(1/b.variance) as variance from w6912i as a,w6912i as b where a.gene ne b.gene group by a.gene;quit;
data w6912m(keep=metric value);set w6912o;length metric $120;array measured[*] beta variance;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6912m;set w6912m;format value best32.;run;
proc export data=w6912m outfile="%sysfunc(pathname(work))/W6912.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6912;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6912:;quit;
