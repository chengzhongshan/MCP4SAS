/* New workflow W6825; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6825i;
length gene $80;
gene='p01';raw_p=0.2;output;
gene='p02';raw_p=0.9512921703249292;output;
gene='p03';raw_p=0.476913699813747;output;
gene='p04';raw_p=0.05;output;
gene='p05';raw_p=0.3037523612216654;output;
gene='p06';raw_p=0.5949588690031186;output;
gene='p07';raw_p=0.005;output;
gene='p08';raw_p=0.17685077768122592;output;
gene='p09';raw_p=0.6646358072057362;output;
gene='p10';raw_p=0.01;output;
gene='p11';raw_p=0.9338536738573475;output;
run;
proc multtest inpvalues=w6825i fdr out=w6825o noprint;run;
data w6825m(keep=metric value);set w6825o;length metric $120;array measured[*] fdr_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6825m;set w6825m;format value best32.;run;
proc export data=w6825m outfile="%sysfunc(pathname(work))/W6825.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6825;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6825:;quit;
