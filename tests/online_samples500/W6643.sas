/* New workflow W6643; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6643i;
length gene $80;
gene='s01';n=25;r=-0.29937278974930676;output;
gene='s02';n=19;r=0.5537082482128737;output;
gene='s03';n=13;r=0.036421865334799186;output;
gene='s04';n=145;r=0.17996547113345562;output;
gene='s05';n=40;r=-0.5290704935934663;output;
gene='s06';n=45;r=0.3140763069372341;output;
run;
data w6643o;set w6643i;z=.5*log((1+r)/(1-r));weight=n-3;variance=1/weight;lower=tanh(z-2.5758293035489*sqrt(variance));upper=tanh(z+2.5758293035489*sqrt(variance));run;
data w6643m(keep=metric value);set w6643o;length metric $120;array measured[*] z variance lower upper;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6643m;set w6643m;format value best32.;run;
proc export data=w6643m outfile="%sysfunc(pathname(work))/W6643.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6643;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6643:;quit;
