/* New workflow W6655; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6655i;
length gene $80;
gene='s01';n=29;r=-0.33578445773894056;output;
gene='s02';n=111;r=-0.5505855422581468;output;
gene='s03';n=146;r=-0.548437560989663;output;
gene='s04';n=67;r=-0.5770648540348011;output;
run;
data w6655o;set w6655i;z=.5*log((1+r)/(1-r));weight=n-3;variance=1/weight;lower=tanh(z-2.5758293035489*sqrt(variance));upper=tanh(z+2.5758293035489*sqrt(variance));run;
data w6655m(keep=metric value);set w6655o;length metric $120;array measured[*] z variance lower upper;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6655m;set w6655m;format value best32.;run;
proc export data=w6655m outfile="%sysfunc(pathname(work))/W6655.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6655;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6655:;quit;
