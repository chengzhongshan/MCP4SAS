/* New workflow W6759; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6759i;
length gene $80;
gene='p01';raw_p=0;output;
gene='p02';raw_p=0.35980147782824135;output;
gene='p03';raw_p=0.6033186810825231;output;
gene='p04';raw_p=1;output;
gene='p05';raw_p=0.8412177948025436;output;
gene='p06';raw_p=0.026633196943865567;output;
gene='p07';raw_p=0.01;output;
gene='p08';raw_p=0.33411087071619616;output;
gene='p09';raw_p=0.7075203126765517;output;
gene='p10';raw_p=0.05;output;
gene='p11';raw_p=0.6470919821784107;output;
run;
proc multtest inpvalues=w6759i sid out=w6759o noprint;run;
data w6759m(keep=metric value);set w6759o;length metric $120;array measured[*] sid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6759m;set w6759m;format value best32.;run;
proc export data=w6759m outfile="%sysfunc(pathname(work))/W6759.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6759;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6759:;quit;
