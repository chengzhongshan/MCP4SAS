/* New workflow W6860; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6860i;
length gene $80;
gene='p01';raw_p=0.05;output;
gene='p02';raw_p=0.0846271262410272;output;
gene='p03';raw_p=0.2218456756797016;output;
gene='p04';raw_p=1;output;
gene='p05';raw_p=0.35920156340183507;output;
gene='p06';raw_p=0.431465662754309;output;
gene='p07';raw_p=1;output;
gene='p08';raw_p=0.39495654701593397;output;
gene='p09';raw_p=0.9488651282403472;output;
gene='p10';raw_p=0.01;output;
gene='p11';raw_p=0.18464857899954434;output;
gene='p12';raw_p=0.14735694599846216;output;
run;
proc multtest inpvalues=w6860i dependentfdr out=w6860o noprint;run;
data w6860m(keep=metric value);set w6860o;length metric $120;array measured[*] dfdr_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6860m;set w6860m;format value best32.;run;
proc export data=w6860m outfile="%sysfunc(pathname(work))/W6860.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6860;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6860:;quit;
