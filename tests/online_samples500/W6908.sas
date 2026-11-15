/* New workflow W6908; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6908i;
length gene $80;
gene='s01';effect=-0.3859000114121125;variance=0.20360777418475226;output;
gene='s02';effect=0.9986273769089737;variance=0.045975177797547284;output;
gene='s03';effect=0.5509974723600206;variance=0.19575255156061933;output;
gene='s04';effect=0.08835733091635256;variance=0.08427572520932686;output;
run;
proc sql;create table w6908o as select a.gene,sum(b.effect/b.variance)/sum(1/b.variance) as beta,1/sum(1/b.variance) as variance from w6908i as a,w6908i as b where a.gene ne b.gene group by a.gene;quit;
data w6908m(keep=metric value);set w6908o;length metric $120;array measured[*] beta variance;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6908m;set w6908m;format value best32.;run;
proc export data=w6908m outfile="%sysfunc(pathname(work))/W6908.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6908;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6908:;quit;
