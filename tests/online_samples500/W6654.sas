/* New workflow W6654; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6654i;
length gene $80;
gene='s01';n=96;r=0.16664487660904137;output;
gene='s02';n=112;r=-0.22861067999807644;output;
gene='s03';n=27;r=0.5036715084441215;output;
run;
data w6654o;set w6654i;z=.5*log((1+r)/(1-r));weight=n-3;variance=1/weight;lower=tanh(z-1.9599639845400536*sqrt(variance));upper=tanh(z+1.9599639845400536*sqrt(variance));run;
data w6654m(keep=metric value);set w6654o;length metric $120;array measured[*] z variance lower upper;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6654m;set w6654m;format value best32.;run;
proc export data=w6654m outfile="%sysfunc(pathname(work))/W6654.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6654;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6654:;quit;
