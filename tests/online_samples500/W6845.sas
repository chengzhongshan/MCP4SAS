/* New workflow W6845; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6845i;
length gene $80;
gene='p01';raw_p=0.001;output;
gene='p02';raw_p=0.1085035717008801;output;
gene='p03';raw_p=0.9187224879433604;output;
gene='p04';raw_p=0.005;output;
gene='p05';raw_p=0.8152481023493527;output;
gene='p06';raw_p=0.05585354082615335;output;
gene='p07';raw_p=0.01;output;
gene='p08';raw_p=0.6272357859496823;output;
gene='p09';raw_p=0.9254671209971971;output;
gene='p10';raw_p=0.005;output;
gene='p11';raw_p=0.8683975938541566;output;
run;
proc multtest inpvalues=w6845i dependentfdr out=w6845o noprint;run;
data w6845m(keep=metric value);set w6845o;length metric $120;array measured[*] dfdr_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6845m;set w6845m;format value best32.;run;
proc export data=w6845m outfile="%sysfunc(pathname(work))/W6845.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6845;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6845:;quit;
