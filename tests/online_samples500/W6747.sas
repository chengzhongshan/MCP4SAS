/* New workflow W6747; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6747i;
length gene $80;
gene='p01';raw_p=0.001;output;
gene='p02';raw_p=0.4117453174501674;output;
gene='p03';raw_p=0.015512949132329257;output;
gene='p04';raw_p=0.05;output;
gene='p05';raw_p=0.6292575584297164;output;
gene='p06';raw_p=0.03686859018923416;output;
run;
proc multtest inpvalues=w6747i sid out=w6747o noprint;run;
data w6747m(keep=metric value);set w6747o;length metric $120;array measured[*] sid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6747m;set w6747m;format value best32.;run;
proc export data=w6747m outfile="%sysfunc(pathname(work))/W6747.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6747;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6747:;quit;
