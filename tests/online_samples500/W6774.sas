/* New workflow W6774; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6774i;
length gene $80;
gene='p01';raw_p=0;output;
gene='p02';raw_p=0.2962352589723777;output;
gene='p03';raw_p=0.388436649334713;output;
gene='p04';raw_p=0.2;output;
gene='p05';raw_p=0.6210918392007109;output;
gene='p06';raw_p=0.42775966692009804;output;
run;
proc multtest inpvalues=w6774i holm out=w6774o noprint;run;
data w6774m(keep=metric value);set w6774o;length metric $120;array measured[*] stpbon_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6774m;set w6774m;format value best32.;run;
proc export data=w6774m outfile="%sysfunc(pathname(work))/W6774.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6774;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6774:;quit;
