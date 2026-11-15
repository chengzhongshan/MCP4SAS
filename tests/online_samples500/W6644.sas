/* New workflow W6644; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6644i;
length gene $80;
gene='s01';n=113;r=0.3931029170625071;output;
gene='s02';n=40;r=0.5402911496106195;output;
gene='s03';n=103;r=-0.09860936199363568;output;
gene='s04';n=88;r=0.6720827039814179;output;
gene='s05';n=110;r=0.18498045579392675;output;
gene='s06';n=112;r=0.4760036790939475;output;
gene='s07';n=20;r=0.2750939076138732;output;
run;
data w6644o;set w6644i;z=.5*log((1+r)/(1-r));weight=n-3;variance=1/weight;lower=tanh(z-1.2815515655446008*sqrt(variance));upper=tanh(z+1.2815515655446008*sqrt(variance));run;
data w6644m(keep=metric value);set w6644o;length metric $120;array measured[*] z variance lower upper;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6644m;set w6644m;format value best32.;run;
proc export data=w6644m outfile="%sysfunc(pathname(work))/W6644.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6644;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6644:;quit;
