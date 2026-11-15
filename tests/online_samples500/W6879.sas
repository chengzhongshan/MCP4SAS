/* New workflow W6879; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6879i;
length gene $80;
gene='p01';raw_p=1e-05;output;
gene='p02';raw_p=0.8779728231862289;output;
gene='p03';raw_p=0.6229484602723877;output;
gene='p04';raw_p=0.001;output;
gene='p05';raw_p=0.8746820908724469;output;
gene='p06';raw_p=0.558376365576334;output;
gene='p07';raw_p=0;output;
gene='p08';raw_p=0.22144159279857956;output;
gene='p09';raw_p=0.017898516070827708;output;
gene='p10';raw_p=0.05;output;
gene='p11';raw_p=0.3236561157784906;output;
run;
data w6879o;set w6879i;retain adjusted 0;adjusted=max(adjusted,raw_p);run;
data w6879m(keep=metric value);set w6879o;length metric $120;array measured[*] adjusted;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6879m;set w6879m;format value best32.;run;
proc export data=w6879m outfile="%sysfunc(pathname(work))/W6879.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6879;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6879:;quit;
