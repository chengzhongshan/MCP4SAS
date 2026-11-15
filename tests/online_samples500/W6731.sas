/* New workflow W6731; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6731i;
length gene $80;
gene='p01';raw_p=1e-05;output;
gene='p02';raw_p=0.30611109406262627;output;
gene='p03';raw_p=0.5012406327683112;output;
gene='p04';raw_p=0.001;output;
gene='p05';raw_p=0.1689493556950722;output;
gene='p06';raw_p=0.05581672280486771;output;
gene='p07';raw_p=1e-05;output;
gene='p08';raw_p=0.746065923661518;output;
gene='p09';raw_p=0.8444954386370792;output;
gene='p10';raw_p=0.001;output;
run;
proc multtest inpvalues=w6731i bon out=w6731o noprint;run;
data w6731m(keep=metric value);set w6731o;length metric $120;array measured[*] bon_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6731m;set w6731m;format value best32.;run;
proc export data=w6731m outfile="%sysfunc(pathname(work))/W6731.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6731;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6731:;quit;
