/* New workflow W6633; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6633i;
length gene $80;
gene='s01';n=82;r=-0.15877546150444;output;
gene='s02';n=103;r=-0.12514679704327347;output;
gene='s03';n=129;r=-0.22902758007753637;output;
gene='s04';n=138;r=0.2088229062536633;output;
gene='s05';n=111;r=0.44770405642806965;output;
gene='s06';n=139;r=-0.677000264330676;output;
gene='s07';n=17;r=0.4109128003441642;output;
gene='s08';n=53;r=-0.36771495270056154;output;
gene='s09';n=133;r=-0.4634022974474302;output;
run;
data w6633o;set w6633i;z=.5*log((1+r)/(1-r));weight=n-3;variance=1/weight;lower=tanh(z-1.6448536269514715*sqrt(variance));upper=tanh(z+1.6448536269514715*sqrt(variance));run;
proc sql;create table w6633pool as select "pooled" as gene,sum(weight*z)/sum(weight) as z,1/sum(weight) as variance from w6633o;quit;data w6633pool;set w6633pool;r=tanh(z);run;
data w6633m(keep=metric value);set w6633pool;length metric $120;array measured[*] z variance r;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6633m;set w6633m;format value best32.;run;
proc export data=w6633m outfile="%sysfunc(pathname(work))/W6633.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6633;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6633:;quit;
