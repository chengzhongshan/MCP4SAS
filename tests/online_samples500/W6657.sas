/* New workflow W6657; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6657i;
length gene $80;
gene='s01';n=77;r=0.3881529470309526;output;
gene='s02';n=41;r=0.4598987011690798;output;
gene='s03';n=35;r=-0.24669255066971696;output;
gene='s04';n=86;r=0.36229132968132327;output;
gene='s05';n=100;r=-0.16787111319153025;output;
gene='s06';n=111;r=-0.19882608058061468;output;
run;
data w6657o;set w6657i;z=.5*log((1+r)/(1-r));weight=n-3;variance=1/weight;lower=tanh(z-1.6448536269514715*sqrt(variance));upper=tanh(z+1.6448536269514715*sqrt(variance));run;
data w6657m(keep=metric value);set w6657o;length metric $120;array measured[*] z variance lower upper;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6657m;set w6657m;format value best32.;run;
proc export data=w6657m outfile="%sysfunc(pathname(work))/W6657.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6657;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6657:;quit;
