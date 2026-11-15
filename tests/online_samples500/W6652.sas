/* New workflow W6652; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6652i;
length gene $80;
gene='s01';n=120;r=0.6793155101490496;output;
gene='s02';n=67;r=-0.11183374925301859;output;
gene='s03';n=121;r=0.2449903110184367;output;
gene='s04';n=145;r=0.4639110362642125;output;
gene='s05';n=34;r=-0.6783215202673323;output;
gene='s06';n=103;r=0.41334273110524244;output;
gene='s07';n=33;r=0.6063103285454052;output;
gene='s08';n=46;r=0.42190190950212747;output;
run;
data w6652o;set w6652i;z=.5*log((1+r)/(1-r));weight=n-3;variance=1/weight;lower=tanh(z-1.2815515655446008*sqrt(variance));upper=tanh(z+1.2815515655446008*sqrt(variance));run;
data w6652m(keep=metric value);set w6652o;length metric $120;array measured[*] z variance lower upper;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6652m;set w6652m;format value best32.;run;
proc export data=w6652m outfile="%sysfunc(pathname(work))/W6652.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6652;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6652:;quit;
