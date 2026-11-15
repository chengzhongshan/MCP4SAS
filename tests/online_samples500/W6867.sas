/* New workflow W6867; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6867i;
length gene $80;
gene='p01';raw_p=0.2;output;
gene='p02';raw_p=0.4046805164683269;output;
gene='p03';raw_p=0.03970619518793772;output;
gene='p04';raw_p=0.05;output;
gene='p05';raw_p=0.6773423055664217;output;
gene='p06';raw_p=0.2867503329323493;output;
run;
data w6867o;set w6867i;retain adjusted 0;adjusted=max(adjusted,raw_p);run;
data w6867m(keep=metric value);set w6867o;length metric $120;array measured[*] adjusted;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6867m;set w6867m;format value best32.;run;
proc export data=w6867m outfile="%sysfunc(pathname(work))/W6867.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6867;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6867:;quit;
