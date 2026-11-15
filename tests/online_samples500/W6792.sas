/* New workflow W6792; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6792i;
length gene $80;
gene='p01';raw_p=0.001;output;
gene='p02';raw_p=0.5561237179485331;output;
gene='p03';raw_p=0.22345982510215479;output;
gene='p04';raw_p=0.001;output;
gene='p05';raw_p=0.3847307817801636;output;
gene='p06';raw_p=0.18589762379456398;output;
gene='p07';raw_p=0.01;output;
gene='p08';raw_p=0.2546573835971634;output;
gene='p09';raw_p=0.8879770342148888;output;
gene='p10';raw_p=0.01;output;
gene='p11';raw_p=0.39198879137195375;output;
run;
proc multtest inpvalues=w6792i stepsid out=w6792o noprint;run;
data w6792m(keep=metric value);set w6792o;length metric $120;array measured[*] stpsid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6792m;set w6792m;format value best32.;run;
proc export data=w6792m outfile="%sysfunc(pathname(work))/W6792.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6792;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6792:;quit;
