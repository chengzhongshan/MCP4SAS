/* New workflow W6651; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6651i;
length gene $80;
gene='s01';n=69;r=0.3977733564320638;output;
gene='s02';n=86;r=0.5053083383064922;output;
gene='s03';n=138;r=0.36593856317455886;output;
gene='s04';n=36;r=-0.5087304660713776;output;
gene='s05';n=109;r=-0.23590859944655412;output;
gene='s06';n=116;r=0.4512597593958063;output;
gene='s07';n=16;r=-0.6599290220385399;output;
run;
data w6651o;set w6651i;z=.5*log((1+r)/(1-r));weight=n-3;variance=1/weight;lower=tanh(z-2.5758293035489*sqrt(variance));upper=tanh(z+2.5758293035489*sqrt(variance));run;
data w6651m(keep=metric value);set w6651o;length metric $120;array measured[*] z variance lower upper;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6651m;set w6651m;format value best32.;run;
proc export data=w6651m outfile="%sysfunc(pathname(work))/W6651.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6651;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6651:;quit;
