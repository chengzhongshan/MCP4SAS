/* New workflow W6880; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6880i;
length gene $80;
gene='p01';raw_p=1e-05;output;
gene='p02';raw_p=0.1276798090826905;output;
gene='p03';raw_p=0.23677761097197214;output;
gene='p04';raw_p=0.8;output;
gene='p05';raw_p=0.5589074105602824;output;
gene='p06';raw_p=0.3016165115901529;output;
gene='p07';raw_p=0.01;output;
gene='p08';raw_p=0.6175138137914847;output;
gene='p09';raw_p=0.9072361858562118;output;
gene='p10';raw_p=0.005;output;
gene='p11';raw_p=0.5420591511678833;output;
gene='p12';raw_p=0.011554713233549063;output;
run;
data w6880o;set w6880i;retain adjusted 0;adjusted=max(adjusted,raw_p);run;
data w6880m(keep=metric value);set w6880o;length metric $120;array measured[*] adjusted;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6880m;set w6880m;format value best32.;run;
proc export data=w6880m outfile="%sysfunc(pathname(work))/W6880.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6880;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6880:;quit;
