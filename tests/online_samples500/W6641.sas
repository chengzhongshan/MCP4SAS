/* New workflow W6641; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6641i;
length gene $80;
gene='s01';n=72;r=-0.3458487342005965;output;
gene='s02';n=145;r=0.5736591583407225;output;
gene='s03';n=12;r=-0.571432973667697;output;
gene='s04';n=55;r=-0.46894847695810665;output;
run;
data w6641o;set w6641i;z=.5*log((1+r)/(1-r));weight=n-3;variance=1/weight;lower=tanh(z-1.6448536269514715*sqrt(variance));upper=tanh(z+1.6448536269514715*sqrt(variance));run;
data w6641m(keep=metric value);set w6641o;length metric $120;array measured[*] z variance lower upper;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6641m;set w6641m;format value best32.;run;
proc export data=w6641m outfile="%sysfunc(pathname(work))/W6641.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6641;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6641:;quit;
