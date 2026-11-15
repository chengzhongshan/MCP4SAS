/* New workflow W6873; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6873i;
length gene $80;
gene='p01';raw_p=0.05;output;
gene='p02';raw_p=0.5285154602402159;output;
gene='p03';raw_p=0.38416521723789376;output;
gene='p04';raw_p=0.01;output;
gene='p05';raw_p=0.3378506244948576;output;
gene='p06';raw_p=0.49281058372315034;output;
gene='p07';raw_p=0;output;
gene='p08';raw_p=0.5452186304401245;output;
gene='p09';raw_p=0.06626973550613857;output;
gene='p10';raw_p=0.2;output;
gene='p11';raw_p=0.6133274900583094;output;
gene='p12';raw_p=0.4263058614677817;output;
run;
data w6873o;set w6873i;retain adjusted 0;adjusted=max(adjusted,raw_p);run;
data w6873m(keep=metric value);set w6873o;length metric $120;array measured[*] adjusted;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6873m;set w6873m;format value best32.;run;
proc export data=w6873m outfile="%sysfunc(pathname(work))/W6873.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6873;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6873:;quit;
