/* New workflow W6851; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6851i;
length gene $80;
gene='p01';raw_p=1e-05;output;
gene='p02';raw_p=0.5460438241985555;output;
gene='p03';raw_p=0.37012881435400946;output;
gene='p04';raw_p=0.001;output;
gene='p05';raw_p=0.19936446168427657;output;
gene='p06';raw_p=0.7066942092034739;output;
gene='p07';raw_p=0.01;output;
gene='p08';raw_p=0.1506002640678329;output;
gene='p09';raw_p=0.7292358378233923;output;
gene='p10';raw_p=0.2;output;
run;
proc multtest inpvalues=w6851i dependentfdr out=w6851o noprint;run;
data w6851m(keep=metric value);set w6851o;length metric $120;array measured[*] dfdr_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6851m;set w6851m;format value best32.;run;
proc export data=w6851m outfile="%sysfunc(pathname(work))/W6851.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6851;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6851:;quit;
