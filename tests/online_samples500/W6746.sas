/* New workflow W6746; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6746i;
length gene $80;
gene='p01';raw_p=0.01;output;
gene='p02';raw_p=0.917815048125125;output;
gene='p03';raw_p=0.08181358734259081;output;
gene='p04';raw_p=0.01;output;
gene='p05';raw_p=0.24600169764815294;output;
gene='p06';raw_p=0.7379072781781048;output;
gene='p07';raw_p=0.05;output;
gene='p08';raw_p=0.6269141712874934;output;
gene='p09';raw_p=0.39340002103200844;output;
gene='p10';raw_p=1e-05;output;
gene='p11';raw_p=0.8191322873705987;output;
gene='p12';raw_p=0.9975370940322704;output;
run;
proc multtest inpvalues=w6746i sid out=w6746o noprint;run;
data w6746m(keep=metric value);set w6746o;length metric $120;array measured[*] sid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6746m;set w6746m;format value best32.;run;
proc export data=w6746m outfile="%sysfunc(pathname(work))/W6746.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6746;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6746:;quit;
