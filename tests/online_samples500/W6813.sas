/* New workflow W6813; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6813i;
length gene $80;
gene='p01';raw_p=0.001;output;
gene='p02';raw_p=0.8249474472806243;output;
gene='p03';raw_p=0.15110949199362078;output;
gene='p04';raw_p=0;output;
gene='p05';raw_p=0.19973088539239003;output;
gene='p06';raw_p=0.8380688077301253;output;
gene='p07';raw_p=0.2;output;
gene='p08';raw_p=0.9272407706407727;output;
gene='p09';raw_p=0.41141825692829115;output;
gene='p10';raw_p=1e-05;output;
gene='p11';raw_p=0.4864885023503095;output;
gene='p12';raw_p=0.8551465801114293;output;
run;
proc multtest inpvalues=w6813i hoc out=w6813o noprint;run;
data w6813m(keep=metric value);set w6813o;length metric $120;array measured[*] hoc_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6813m;set w6813m;format value best32.;run;
proc export data=w6813m outfile="%sysfunc(pathname(work))/W6813.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6813;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6813:;quit;
