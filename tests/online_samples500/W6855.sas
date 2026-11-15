/* New workflow W6855; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6855i;
length gene $80;
gene='p01';raw_p=0.8;output;
gene='p02';raw_p=0.9630572150407984;output;
gene='p03';raw_p=0.792209865403985;output;
gene='p04';raw_p=0.8;output;
gene='p05';raw_p=0.3339594169860173;output;
gene='p06';raw_p=0.9502738977756702;output;
gene='p07';raw_p=0.05;output;
run;
proc multtest inpvalues=w6855i dependentfdr out=w6855o noprint;run;
data w6855m(keep=metric value);set w6855o;length metric $120;array measured[*] dfdr_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6855m;set w6855m;format value best32.;run;
proc export data=w6855m outfile="%sysfunc(pathname(work))/W6855.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6855;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6855:;quit;
