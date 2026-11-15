/* New workflow W6730; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6730i;
length gene $80;
gene='p01';raw_p=0.8;output;
gene='p02';raw_p=0.14848397281604864;output;
gene='p03';raw_p=0.3029854472387532;output;
gene='p04';raw_p=0;output;
gene='p05';raw_p=0.6924949420356019;output;
gene='p06';raw_p=0.5353149245398287;output;
gene='p07';raw_p=0.005;output;
gene='p08';raw_p=0.22120172653509906;output;
gene='p09';raw_p=0.48465352538842776;output;
run;
proc multtest inpvalues=w6730i bon out=w6730o noprint;run;
data w6730m(keep=metric value);set w6730o;length metric $120;array measured[*] bon_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6730m;set w6730m;format value best32.;run;
proc export data=w6730m outfile="%sysfunc(pathname(work))/W6730.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6730;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6730:;quit;
