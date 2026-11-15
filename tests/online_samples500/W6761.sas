/* New workflow W6761; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6761i;
length gene $80;
gene='p01';raw_p=1;output;
gene='p02';raw_p=0.26134571043917587;output;
gene='p03';raw_p=0.9474928308536869;output;
gene='p04';raw_p=0.001;output;
gene='p05';raw_p=0.8798675129583543;output;
gene='p06';raw_p=0.8665809657480831;output;
gene='p07';raw_p=0.01;output;
run;
proc multtest inpvalues=w6761i holm out=w6761o noprint;run;
data w6761m(keep=metric value);set w6761o;length metric $120;array measured[*] stpbon_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6761m;set w6761m;format value best32.;run;
proc export data=w6761m outfile="%sysfunc(pathname(work))/W6761.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6761;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6761:;quit;
