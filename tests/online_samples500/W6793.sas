/* New workflow W6793; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6793i;
length gene $80;
gene='p01';raw_p=1e-05;output;
gene='p02';raw_p=0.5613097719933725;output;
gene='p03';raw_p=0.8035218518996651;output;
gene='p04';raw_p=0.2;output;
gene='p05';raw_p=0.756326184188482;output;
gene='p06';raw_p=0.30764594837365755;output;
gene='p07';raw_p=0.05;output;
gene='p08';raw_p=0.472072562654974;output;
gene='p09';raw_p=0.8616962335751794;output;
gene='p10';raw_p=0.01;output;
gene='p11';raw_p=0.009996650570991306;output;
gene='p12';raw_p=0.585796604268903;output;
run;
proc multtest inpvalues=w6793i stepsid out=w6793o noprint;run;
data w6793m(keep=metric value);set w6793o;length metric $120;array measured[*] stpsid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6793m;set w6793m;format value best32.;run;
proc export data=w6793m outfile="%sysfunc(pathname(work))/W6793.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6793;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6793:;quit;
