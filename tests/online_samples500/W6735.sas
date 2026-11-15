/* New workflow W6735; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6735i;
length gene $80;
gene='p01';raw_p=0.05;output;
gene='p02';raw_p=0.7365364609423244;output;
gene='p03';raw_p=0.1542391380010787;output;
gene='p04';raw_p=0.001;output;
gene='p05';raw_p=0.20312978426419992;output;
gene='p06';raw_p=0.9259317972106538;output;
gene='p07';raw_p=0.2;output;
run;
proc multtest inpvalues=w6735i bon out=w6735o noprint;run;
data w6735m(keep=metric value);set w6735o;length metric $120;array measured[*] bon_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6735m;set w6735m;format value best32.;run;
proc export data=w6735m outfile="%sysfunc(pathname(work))/W6735.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6735;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6735:;quit;
