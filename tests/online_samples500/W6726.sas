/* New workflow W6726; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6726i;
length gene $80;
gene='p01';raw_p=0.2;output;
gene='p02';raw_p=0.1616175113900714;output;
gene='p03';raw_p=0.7133280408927835;output;
gene='p04';raw_p=0.8;output;
gene='p05';raw_p=0.7800683130421983;output;
gene='p06';raw_p=0.5308415298331329;output;
gene='p07';raw_p=0;output;
gene='p08';raw_p=0.7008822599703647;output;
gene='p09';raw_p=0.986752886417325;output;
gene='p10';raw_p=0.8;output;
gene='p11';raw_p=0.7115666435502036;output;
gene='p12';raw_p=0.9675551824871307;output;
run;
proc multtest inpvalues=w6726i bon out=w6726o noprint;run;
data w6726m(keep=metric value);set w6726o;length metric $120;array measured[*] bon_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6726m;set w6726m;format value best32.;run;
proc export data=w6726m outfile="%sysfunc(pathname(work))/W6726.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6726;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6726:;quit;
