/* New workflow W6660; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6660i;
length gene $80;
gene='s01';n=134;r=0.16348289247507453;output;
gene='s02';n=82;r=-0.004965906876362558;output;
gene='s03';n=40;r=-0.5277596094538468;output;
gene='s04';n=48;r=0.43456032365284547;output;
gene='s05';n=144;r=-0.5010632696084849;output;
gene='s06';n=81;r=0.11844472872766865;output;
gene='s07';n=35;r=0.6336283912780489;output;
gene='s08';n=129;r=0.24726948066263965;output;
gene='s09';n=35;r=0.5041477425686516;output;
run;
data w6660o;set w6660i;z=.5*log((1+r)/(1-r));weight=n-3;variance=1/weight;lower=tanh(z-1.2815515655446008*sqrt(variance));upper=tanh(z+1.2815515655446008*sqrt(variance));run;
data w6660m(keep=metric value);set w6660o;length metric $120;array measured[*] z variance lower upper;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6660m;set w6660m;format value best32.;run;
proc export data=w6660m outfile="%sysfunc(pathname(work))/W6660.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6660;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6660:;quit;
