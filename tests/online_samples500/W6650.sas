/* New workflow W6650; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6650i;
length gene $80;
gene='s01';n=37;r=-0.10772689009731151;output;
gene='s02';n=21;r=-0.013545790577101924;output;
gene='s03';n=66;r=0.46346487613256593;output;
gene='s04';n=95;r=0.2632870437496274;output;
gene='s05';n=79;r=0.5486034008654379;output;
gene='s06';n=20;r=0.14518667477014668;output;
run;
data w6650o;set w6650i;z=.5*log((1+r)/(1-r));weight=n-3;variance=1/weight;lower=tanh(z-1.9599639845400536*sqrt(variance));upper=tanh(z+1.9599639845400536*sqrt(variance));run;
data w6650m(keep=metric value);set w6650o;length metric $120;array measured[*] z variance lower upper;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6650m;set w6650m;format value best32.;run;
proc export data=w6650m outfile="%sysfunc(pathname(work))/W6650.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6650;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6650:;quit;
