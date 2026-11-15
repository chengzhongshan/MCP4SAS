/* New workflow W6656; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6656i;
length gene $80;
gene='s01';n=48;r=0.3645942106673268;output;
gene='s02';n=38;r=0.21907235535191583;output;
gene='s03';n=85;r=0.11158327021467418;output;
gene='s04';n=104;r=-0.15227449347424904;output;
gene='s05';n=146;r=0.04036436011519462;output;
run;
data w6656o;set w6656i;z=.5*log((1+r)/(1-r));weight=n-3;variance=1/weight;lower=tanh(z-1.2815515655446008*sqrt(variance));upper=tanh(z+1.2815515655446008*sqrt(variance));run;
data w6656m(keep=metric value);set w6656o;length metric $120;array measured[*] z variance lower upper;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6656m;set w6656m;format value best32.;run;
proc export data=w6656m outfile="%sysfunc(pathname(work))/W6656.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6656;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6656:;quit;
