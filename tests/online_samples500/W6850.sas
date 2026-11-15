/* New workflow W6850; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6850i;
length gene $80;
gene='p01';raw_p=0;output;
gene='p02';raw_p=0.8487973015176264;output;
gene='p03';raw_p=0.5656258499975438;output;
gene='p04';raw_p=0.05;output;
gene='p05';raw_p=0.8443829867387783;output;
gene='p06';raw_p=0.9776122603832134;output;
gene='p07';raw_p=1;output;
gene='p08';raw_p=0.802540043884844;output;
gene='p09';raw_p=0.17947924370305868;output;
run;
proc multtest inpvalues=w6850i dependentfdr out=w6850o noprint;run;
data w6850m(keep=metric value);set w6850o;length metric $120;array measured[*] dfdr_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6850m;set w6850m;format value best32.;run;
proc export data=w6850m outfile="%sysfunc(pathname(work))/W6850.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6850;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6850:;quit;
