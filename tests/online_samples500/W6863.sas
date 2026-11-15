/* New workflow W6863; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6863i;
length gene $80;
gene='p01';raw_p=0.05;output;
gene='p02';raw_p=0.08739936239904456;output;
gene='p03';raw_p=0.4319445545235404;output;
gene='p04';raw_p=0.8;output;
gene='p05';raw_p=0.9594233041565045;output;
gene='p06';raw_p=0.9493975202110493;output;
gene='p07';raw_p=0.05;output;
gene='p08';raw_p=0.5520213612466728;output;
gene='p09';raw_p=0.7943814301133938;output;
run;
data w6863o;set w6863i;retain adjusted 0;adjusted=max(adjusted,raw_p);run;
data w6863m(keep=metric value);set w6863o;length metric $120;array measured[*] adjusted;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6863m;set w6863m;format value best32.;run;
proc export data=w6863m outfile="%sysfunc(pathname(work))/W6863.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6863;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6863:;quit;
