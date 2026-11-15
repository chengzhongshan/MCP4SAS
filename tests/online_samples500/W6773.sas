/* New workflow W6773; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6773i;
length gene $80;
gene='p01';raw_p=0.8;output;
gene='p02';raw_p=0.5468469681825996;output;
gene='p03';raw_p=0.05119186376455176;output;
gene='p04';raw_p=1e-05;output;
gene='p05';raw_p=0.9699703166883175;output;
gene='p06';raw_p=0.656004029090816;output;
gene='p07';raw_p=0;output;
gene='p08';raw_p=0.1261640678218856;output;
gene='p09';raw_p=0.9551448208570733;output;
gene='p10';raw_p=0.2;output;
gene='p11';raw_p=0.262677517340549;output;
gene='p12';raw_p=0.10328490540287749;output;
run;
proc multtest inpvalues=w6773i holm out=w6773o noprint;run;
data w6773m(keep=metric value);set w6773o;length metric $120;array measured[*] stpbon_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6773m;set w6773m;format value best32.;run;
proc export data=w6773m outfile="%sysfunc(pathname(work))/W6773.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6773;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6773:;quit;
