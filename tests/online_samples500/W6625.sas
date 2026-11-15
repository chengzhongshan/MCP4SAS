/* New workflow W6625; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6625i;
length gene $80;
gene='s01';n=52;r=0.5369336888481604;output;
gene='s02';n=120;r=0.38532574636656736;output;
gene='s03';n=58;r=-0.3322585184315987;output;
gene='s04';n=142;r=-0.35589613154239697;output;
gene='s05';n=51;r=0.139988257292206;output;
gene='s06';n=28;r=-0.48190554114113293;output;
gene='s07';n=84;r=-0.4537676035357098;output;
gene='s08';n=110;r=-0.16930064258274657;output;
run;
data w6625o;set w6625i;z=.5*log((1+r)/(1-r));weight=n-3;variance=1/weight;lower=tanh(z-1.6448536269514715*sqrt(variance));upper=tanh(z+1.6448536269514715*sqrt(variance));run;
proc sql;create table w6625pool as select "pooled" as gene,sum(weight*z)/sum(weight) as z,1/sum(weight) as variance from w6625o;quit;data w6625pool;set w6625pool;r=tanh(z);run;
data w6625m(keep=metric value);set w6625pool;length metric $120;array measured[*] z variance r;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6625m;set w6625m;format value best32.;run;
proc export data=w6625m outfile="%sysfunc(pathname(work))/W6625.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6625;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6625:;quit;
