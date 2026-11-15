/* New workflow W6820; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6820i;
length gene $80;
gene='p01';raw_p=0.01;output;
gene='p02';raw_p=0.3714796844840692;output;
gene='p03';raw_p=0.8626813225429112;output;
gene='p04';raw_p=0.05;output;
gene='p05';raw_p=0.6339854509939362;output;
gene='p06';raw_p=0.2279600337885911;output;
gene='p07';raw_p=0.05;output;
gene='p08';raw_p=0.45380870805651574;output;
gene='p09';raw_p=0.13829876238236705;output;
gene='p10';raw_p=0.005;output;
gene='p11';raw_p=0.5631847695261242;output;
gene='p12';raw_p=0.9906532297912813;output;
run;
proc multtest inpvalues=w6820i hoc out=w6820o noprint;run;
data w6820m(keep=metric value);set w6820o;length metric $120;array measured[*] hoc_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6820m;set w6820m;format value best32.;run;
proc export data=w6820m outfile="%sysfunc(pathname(work))/W6820.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6820;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6820:;quit;
