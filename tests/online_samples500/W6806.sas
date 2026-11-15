/* New workflow W6806; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6806i;
length gene $80;
gene='p01';raw_p=0.01;output;
gene='p02';raw_p=0.742579969326055;output;
gene='p03';raw_p=0.8066730683576887;output;
gene='p04';raw_p=1e-05;output;
gene='p05';raw_p=0.750895996698052;output;
gene='p06';raw_p=0.37245160997695126;output;
gene='p07';raw_p=0.2;output;
gene='p08';raw_p=0.8756594592108111;output;
gene='p09';raw_p=0.2520598658198909;output;
gene='p10';raw_p=1e-05;output;
gene='p11';raw_p=0.18309023888267784;output;
gene='p12';raw_p=0.4598917708677196;output;
run;
proc multtest inpvalues=w6806i hoc out=w6806o noprint;run;
data w6806m(keep=metric value);set w6806o;length metric $120;array measured[*] hoc_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6806m;set w6806m;format value best32.;run;
proc export data=w6806m outfile="%sysfunc(pathname(work))/W6806.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6806;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6806:;quit;
