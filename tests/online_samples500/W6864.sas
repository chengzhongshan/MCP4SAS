/* New workflow W6864; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6864i;
length gene $80;
gene='p01';raw_p=0.8;output;
gene='p02';raw_p=0.8985576759254044;output;
gene='p03';raw_p=0.38592329456905483;output;
gene='p04';raw_p=1;output;
gene='p05';raw_p=0.9302241866329128;output;
gene='p06';raw_p=0.6931593959351516;output;
gene='p07';raw_p=1e-05;output;
gene='p08';raw_p=0.5327455406685204;output;
gene='p09';raw_p=0.10754398851929081;output;
gene='p10';raw_p=1;output;
run;
data w6864o;set w6864i;retain adjusted 0;adjusted=max(adjusted,raw_p);run;
data w6864m(keep=metric value);set w6864o;length metric $120;array measured[*] adjusted;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6864m;set w6864m;format value best32.;run;
proc export data=w6864m outfile="%sysfunc(pathname(work))/W6864.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6864;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6864:;quit;
