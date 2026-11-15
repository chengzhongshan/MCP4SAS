/* New workflow W6907; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6907i;
length gene $80;
gene='s01';effect=0.4695980771712267;variance=0.21975023883820577;output;
gene='s02';effect=0.25584310030806034;variance=0.09067221520406751;output;
gene='s03';effect=0.6684152952973217;variance=0.2759519099735564;output;
run;
proc sql;create table w6907o as select a.gene,sum(b.effect/b.variance)/sum(1/b.variance) as beta,1/sum(1/b.variance) as variance from w6907i as a,w6907i as b where a.gene ne b.gene group by a.gene;quit;
data w6907m(keep=metric value);set w6907o;length metric $120;array measured[*] beta variance;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6907m;set w6907m;format value best32.;run;
proc export data=w6907m outfile="%sysfunc(pathname(work))/W6907.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6907;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6907:;quit;
