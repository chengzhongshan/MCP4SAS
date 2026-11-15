/* New workflow W6859; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6859i;
length gene $80;
gene='p01';raw_p=0.001;output;
gene='p02';raw_p=0.1507067743554038;output;
gene='p03';raw_p=0.19782570652331777;output;
gene='p04';raw_p=0.01;output;
gene='p05';raw_p=0.38651990799099145;output;
gene='p06';raw_p=0.886256257912806;output;
gene='p07';raw_p=0.2;output;
gene='p08';raw_p=0.30021914285315043;output;
gene='p09';raw_p=0.007582529357123002;output;
gene='p10';raw_p=1;output;
gene='p11';raw_p=0.7327948677492709;output;
run;
proc multtest inpvalues=w6859i dependentfdr out=w6859o noprint;run;
data w6859m(keep=metric value);set w6859o;length metric $120;array measured[*] dfdr_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6859m;set w6859m;format value best32.;run;
proc export data=w6859m outfile="%sysfunc(pathname(work))/W6859.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6859;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6859:;quit;
