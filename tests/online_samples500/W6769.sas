/* New workflow W6769; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6769i;
length gene $80;
gene='p01';raw_p=0.01;output;
gene='p02';raw_p=0.6723334000980636;output;
gene='p03';raw_p=0.11563793939854183;output;
gene='p04';raw_p=0.01;output;
gene='p05';raw_p=0.0907881803204933;output;
gene='p06';raw_p=0.2668115426109118;output;
gene='p07';raw_p=1;output;
gene='p08';raw_p=0.45708916627128227;output;
run;
proc multtest inpvalues=w6769i holm out=w6769o noprint;run;
data w6769m(keep=metric value);set w6769o;length metric $120;array measured[*] stpbon_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6769m;set w6769m;format value best32.;run;
proc export data=w6769m outfile="%sysfunc(pathname(work))/W6769.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6769;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6769:;quit;
