/* New workflow W6648; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6648i;
length gene $80;
gene='s01';n=43;r=0.015594212513808103;output;
gene='s02';n=17;r=-0.3260873218465713;output;
gene='s03';n=51;r=0.038938433316968335;output;
gene='s04';n=35;r=-0.6231563630737451;output;
run;
data w6648o;set w6648i;z=.5*log((1+r)/(1-r));weight=n-3;variance=1/weight;lower=tanh(z-1.2815515655446008*sqrt(variance));upper=tanh(z+1.2815515655446008*sqrt(variance));run;
data w6648m(keep=metric value);set w6648o;length metric $120;array measured[*] z variance lower upper;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6648m;set w6648m;format value best32.;run;
proc export data=w6648m outfile="%sysfunc(pathname(work))/W6648.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6648;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6648:;quit;
