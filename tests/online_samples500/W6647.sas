/* New workflow W6647; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6647i;
length gene $80;
gene='s01';n=101;r=0.21885147174603847;output;
gene='s02';n=87;r=-0.11139500028623472;output;
gene='s03';n=103;r=0.004544612525445024;output;
run;
data w6647o;set w6647i;z=.5*log((1+r)/(1-r));weight=n-3;variance=1/weight;lower=tanh(z-2.5758293035489*sqrt(variance));upper=tanh(z+2.5758293035489*sqrt(variance));run;
data w6647m(keep=metric value);set w6647o;length metric $120;array measured[*] z variance lower upper;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6647m;set w6647m;format value best32.;run;
proc export data=w6647m outfile="%sysfunc(pathname(work))/W6647.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6647;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6647:;quit;
