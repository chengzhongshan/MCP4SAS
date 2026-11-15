/* New workflow W6649; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6649i;
length gene $80;
gene='s01';n=85;r=-0.4479379777931645;output;
gene='s02';n=18;r=0.13866117261780575;output;
gene='s03';n=37;r=0.30909315537076654;output;
gene='s04';n=33;r=-0.013396258022059793;output;
gene='s05';n=33;r=-0.15009486045357012;output;
run;
data w6649o;set w6649i;z=.5*log((1+r)/(1-r));weight=n-3;variance=1/weight;lower=tanh(z-1.6448536269514715*sqrt(variance));upper=tanh(z+1.6448536269514715*sqrt(variance));run;
data w6649m(keep=metric value);set w6649o;length metric $120;array measured[*] z variance lower upper;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6649m;set w6649m;format value best32.;run;
proc export data=w6649m outfile="%sysfunc(pathname(work))/W6649.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6649;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6649:;quit;
