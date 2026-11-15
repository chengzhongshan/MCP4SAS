/* New workflow W6642; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6642i;
length gene $80;
gene='s01';n=130;r=0.39027301012443183;output;
gene='s02';n=101;r=-0.6967511172265375;output;
gene='s03';n=46;r=-0.23428705752069506;output;
gene='s04';n=34;r=0.57916504769876;output;
gene='s05';n=100;r=0.18238206380462618;output;
run;
data w6642o;set w6642i;z=.5*log((1+r)/(1-r));weight=n-3;variance=1/weight;lower=tanh(z-1.9599639845400536*sqrt(variance));upper=tanh(z+1.9599639845400536*sqrt(variance));run;
data w6642m(keep=metric value);set w6642o;length metric $120;array measured[*] z variance lower upper;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6642m;set w6642m;format value best32.;run;
proc export data=w6642m outfile="%sysfunc(pathname(work))/W6642.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6642;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6642:;quit;
