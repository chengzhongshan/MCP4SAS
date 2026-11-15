/* New workflow W6719; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6719i;
length gene $80;
gene='p01';raw_p=1e-05;output;
gene='p02';raw_p=0.7939116092091569;output;
gene='p03';raw_p=0.22291677303594548;output;
gene='p04';raw_p=0.01;output;
gene='p05';raw_p=0.8676247480534519;output;
gene='p06';raw_p=0.38929672034908436;output;
gene='p07';raw_p=0.05;output;
gene='p08';raw_p=0.19498951892219796;output;
gene='p09';raw_p=0.6654203717756806;output;
gene='p10';raw_p=1;output;
gene='p11';raw_p=0.12197228002655502;output;
run;
data w6719o;set w6719i;bon_p=min(1,11*raw_p);sid_p=1-(1-raw_p)**11;run;
data w6719m(keep=metric value);set w6719o;length metric $120;array measured[*] bon_p sid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6719m;set w6719m;format value best32.;run;
proc export data=w6719m outfile="%sysfunc(pathname(work))/W6719.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6719;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6719:;quit;
