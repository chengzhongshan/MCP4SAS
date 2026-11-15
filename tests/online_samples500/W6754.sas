/* New workflow W6754; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6754i;
length gene $80;
gene='p01';raw_p=0.01;output;
gene='p02';raw_p=0.04339747144976991;output;
gene='p03';raw_p=0.10688040671995314;output;
gene='p04';raw_p=0.2;output;
gene='p05';raw_p=0.04193486117823075;output;
gene='p06';raw_p=0.6223559302141788;output;
run;
proc multtest inpvalues=w6754i sid out=w6754o noprint;run;
data w6754m(keep=metric value);set w6754o;length metric $120;array measured[*] sid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6754m;set w6754m;format value best32.;run;
proc export data=w6754m outfile="%sysfunc(pathname(work))/W6754.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6754;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6754:;quit;
