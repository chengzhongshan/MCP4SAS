/* New workflow W6645; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6645i;
length gene $80;
gene='s01';n=109;r=0.24042514485478383;output;
gene='s02';n=46;r=0.6363873587881144;output;
gene='s03';n=116;r=-0.4205315646411596;output;
gene='s04';n=100;r=0.6488041233421264;output;
gene='s05';n=95;r=0.12401097487256241;output;
gene='s06';n=48;r=0.12536475498396815;output;
gene='s07';n=76;r=-0.05819240821614324;output;
gene='s08';n=140;r=-0.3980327717818483;output;
run;
data w6645o;set w6645i;z=.5*log((1+r)/(1-r));weight=n-3;variance=1/weight;lower=tanh(z-1.6448536269514715*sqrt(variance));upper=tanh(z+1.6448536269514715*sqrt(variance));run;
data w6645m(keep=metric value);set w6645o;length metric $120;array measured[*] z variance lower upper;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6645m;set w6645m;format value best32.;run;
proc export data=w6645m outfile="%sysfunc(pathname(work))/W6645.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6645;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6645:;quit;
