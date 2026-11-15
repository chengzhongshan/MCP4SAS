/* New workflow W6646; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6646i;
length gene $80;
gene='s01';n=118;r=0.3886618628437477;output;
gene='s02';n=105;r=-0.5985248342540535;output;
gene='s03';n=85;r=-0.694414384550229;output;
gene='s04';n=118;r=-0.6446692657042928;output;
gene='s05';n=100;r=-0.4185261496132335;output;
gene='s06';n=43;r=-0.319073112124895;output;
gene='s07';n=28;r=0.21116492013608545;output;
gene='s08';n=147;r=0.100427278962682;output;
gene='s09';n=107;r=0.3526824881761452;output;
run;
data w6646o;set w6646i;z=.5*log((1+r)/(1-r));weight=n-3;variance=1/weight;lower=tanh(z-1.9599639845400536*sqrt(variance));upper=tanh(z+1.9599639845400536*sqrt(variance));run;
data w6646m(keep=metric value);set w6646o;length metric $120;array measured[*] z variance lower upper;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6646m;set w6646m;format value best32.;run;
proc export data=w6646m outfile="%sysfunc(pathname(work))/W6646.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6646;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6646:;quit;
