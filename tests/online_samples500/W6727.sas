/* New workflow W6727; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6727i;
length gene $80;
gene='p01';raw_p=0.8;output;
gene='p02';raw_p=0.6544186107867475;output;
gene='p03';raw_p=0.5542170218598952;output;
gene='p04';raw_p=0.001;output;
gene='p05';raw_p=0.405597379442576;output;
gene='p06';raw_p=0.09498245999117771;output;
run;
proc multtest inpvalues=w6727i bon out=w6727o noprint;run;
data w6727m(keep=metric value);set w6727o;length metric $120;array measured[*] bon_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6727m;set w6727m;format value best32.;run;
proc export data=w6727m outfile="%sysfunc(pathname(work))/W6727.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6727;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6727:;quit;
