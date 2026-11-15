/* New workflow W6869; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6869i;
length gene $80;
gene='p01';raw_p=0;output;
gene='p02';raw_p=0.10103228815312337;output;
gene='p03';raw_p=0.766127653338019;output;
gene='p04';raw_p=0.8;output;
gene='p05';raw_p=0.491171419031347;output;
gene='p06';raw_p=0.537254257145489;output;
gene='p07';raw_p=0.001;output;
gene='p08';raw_p=0.6699190826623542;output;
run;
data w6869o;set w6869i;retain adjusted 0;adjusted=max(adjusted,raw_p);run;
data w6869m(keep=metric value);set w6869o;length metric $120;array measured[*] adjusted;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6869m;set w6869m;format value best32.;run;
proc export data=w6869m outfile="%sysfunc(pathname(work))/W6869.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6869;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6869:;quit;
