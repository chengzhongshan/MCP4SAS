/* New workflow W6790; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6790i;
length gene $80;
gene='p01';raw_p=0.05;output;
gene='p02';raw_p=0.5197821216713989;output;
gene='p03';raw_p=0.24388405305002903;output;
gene='p04';raw_p=0;output;
gene='p05';raw_p=0.1678314039631963;output;
gene='p06';raw_p=0.2530150718233316;output;
gene='p07';raw_p=0.005;output;
gene='p08';raw_p=0.9967968691552785;output;
gene='p09';raw_p=0.0689823018038993;output;
run;
proc multtest inpvalues=w6790i stepsid out=w6790o noprint;run;
data w6790m(keep=metric value);set w6790o;length metric $120;array measured[*] stpsid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6790m;set w6790m;format value best32.;run;
proc export data=w6790m outfile="%sysfunc(pathname(work))/W6790.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6790;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6790:;quit;
