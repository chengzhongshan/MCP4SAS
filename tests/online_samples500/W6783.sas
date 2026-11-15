/* New workflow W6783; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6783i;
length gene $80;
gene='p01';raw_p=0.005;output;
gene='p02';raw_p=0.6322798460829873;output;
gene='p03';raw_p=0.22153702186635849;output;
gene='p04';raw_p=1;output;
gene='p05';raw_p=0.7103075350566749;output;
gene='p06';raw_p=0.7945435963948743;output;
gene='p07';raw_p=1e-05;output;
gene='p08';raw_p=0.6144225776254846;output;
gene='p09';raw_p=0.8429545524714188;output;
run;
proc multtest inpvalues=w6783i stepsid out=w6783o noprint;run;
data w6783m(keep=metric value);set w6783o;length metric $120;array measured[*] stpsid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6783m;set w6783m;format value best32.;run;
proc export data=w6783m outfile="%sysfunc(pathname(work))/W6783.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6783;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6783:;quit;
