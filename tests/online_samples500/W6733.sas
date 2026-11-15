/* New workflow W6733; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6733i;
length gene $80;
gene='p01';raw_p=0.8;output;
gene='p02';raw_p=0.7698192517619945;output;
gene='p03';raw_p=0.030178769149018736;output;
gene='p04';raw_p=0.005;output;
gene='p05';raw_p=0.7823271602270058;output;
gene='p06';raw_p=0.5911314363086426;output;
gene='p07';raw_p=0.01;output;
gene='p08';raw_p=0.8119513173299705;output;
gene='p09';raw_p=0.3597084161395986;output;
gene='p10';raw_p=1;output;
gene='p11';raw_p=0.5312990166279656;output;
gene='p12';raw_p=0.9081807282779001;output;
run;
proc multtest inpvalues=w6733i bon out=w6733o noprint;run;
data w6733m(keep=metric value);set w6733o;length metric $120;array measured[*] bon_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6733m;set w6733m;format value best32.;run;
proc export data=w6733m outfile="%sysfunc(pathname(work))/W6733.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6733;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6733:;quit;
