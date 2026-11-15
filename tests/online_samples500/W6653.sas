/* New workflow W6653; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6653i;
length gene $80;
gene='s01';n=130;r=0.5226872458065297;output;
gene='s02';n=119;r=0.37824519310232385;output;
gene='s03';n=150;r=0.6193455717836871;output;
gene='s04';n=77;r=0.294878798106573;output;
gene='s05';n=150;r=0.537866113958382;output;
gene='s06';n=50;r=0.40885887575479685;output;
gene='s07';n=82;r=-0.5909458455054101;output;
gene='s08';n=97;r=0.08511369949623337;output;
gene='s09';n=101;r=0.17896895243483957;output;
run;
data w6653o;set w6653i;z=.5*log((1+r)/(1-r));weight=n-3;variance=1/weight;lower=tanh(z-1.6448536269514715*sqrt(variance));upper=tanh(z+1.6448536269514715*sqrt(variance));run;
data w6653m(keep=metric value);set w6653o;length metric $120;array measured[*] z variance lower upper;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6653m;set w6653m;format value best32.;run;
proc export data=w6653m outfile="%sysfunc(pathname(work))/W6653.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6653;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6653:;quit;
