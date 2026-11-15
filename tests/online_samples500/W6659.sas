/* New workflow W6659; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6659i;
length gene $80;
gene='s01';n=133;r=-0.34421327300351356;output;
gene='s02';n=144;r=0.6638270443564842;output;
gene='s03';n=50;r=-0.5995856971085708;output;
gene='s04';n=122;r=0.44928214260027577;output;
gene='s05';n=13;r=-0.5428228349412845;output;
gene='s06';n=19;r=-0.4074625713279532;output;
gene='s07';n=59;r=-0.27522289936352357;output;
gene='s08';n=142;r=0.08111858822943052;output;
run;
data w6659o;set w6659i;z=.5*log((1+r)/(1-r));weight=n-3;variance=1/weight;lower=tanh(z-2.5758293035489*sqrt(variance));upper=tanh(z+2.5758293035489*sqrt(variance));run;
data w6659m(keep=metric value);set w6659o;length metric $120;array measured[*] z variance lower upper;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6659m;set w6659m;format value best32.;run;
proc export data=w6659m outfile="%sysfunc(pathname(work))/W6659.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6659;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6659:;quit;
