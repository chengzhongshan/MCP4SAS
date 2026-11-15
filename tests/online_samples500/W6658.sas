/* New workflow W6658; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6658i;
length gene $80;
gene='s01';n=14;r=0.5947743763576778;output;
gene='s02';n=109;r=0.26145670180962277;output;
gene='s03';n=106;r=-0.29932383160349774;output;
gene='s04';n=41;r=-0.45367149135924756;output;
gene='s05';n=28;r=-0.5811407136822193;output;
gene='s06';n=118;r=0.6760838086531191;output;
gene='s07';n=47;r=-0.1368406262563543;output;
run;
data w6658o;set w6658i;z=.5*log((1+r)/(1-r));weight=n-3;variance=1/weight;lower=tanh(z-1.9599639845400536*sqrt(variance));upper=tanh(z+1.9599639845400536*sqrt(variance));run;
data w6658m(keep=metric value);set w6658o;length metric $120;array measured[*] z variance lower upper;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6658m;set w6658m;format value best32.;run;
proc export data=w6658m outfile="%sysfunc(pathname(work))/W6658.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6658;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6658:;quit;
