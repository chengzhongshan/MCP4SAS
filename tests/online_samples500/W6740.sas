/* New workflow W6740; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6740i;
length gene $80;
gene='p01';raw_p=0.2;output;
gene='p02';raw_p=0.30144992369585644;output;
gene='p03';raw_p=0.9887584551082139;output;
gene='p04';raw_p=0;output;
gene='p05';raw_p=0.38789855094215264;output;
gene='p06';raw_p=0.4538122892467106;output;
gene='p07';raw_p=1e-05;output;
gene='p08';raw_p=0.2732674007909702;output;
gene='p09';raw_p=0.5712322295705207;output;
gene='p10';raw_p=1;output;
gene='p11';raw_p=0.12822003865523302;output;
gene='p12';raw_p=0.5473653650534368;output;
run;
proc multtest inpvalues=w6740i bon out=w6740o noprint;run;
data w6740m(keep=metric value);set w6740o;length metric $120;array measured[*] bon_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6740m;set w6740m;format value best32.;run;
proc export data=w6740m outfile="%sysfunc(pathname(work))/W6740.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6740;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6740:;quit;
