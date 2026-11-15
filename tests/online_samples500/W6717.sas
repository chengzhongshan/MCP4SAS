/* New workflow W6717; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6717i;
length gene $80;
gene='p01';raw_p=1e-05;output;
gene='p02';raw_p=0.14065943250708313;output;
gene='p03';raw_p=0.5478799221111503;output;
gene='p04';raw_p=1e-05;output;
gene='p05';raw_p=0.010697856020378205;output;
gene='p06';raw_p=0.3975002278366587;output;
gene='p07';raw_p=0;output;
gene='p08';raw_p=0.9928244050852415;output;
gene='p09';raw_p=0.11151813750776163;output;
run;
data w6717o;set w6717i;bon_p=min(1,9*raw_p);sid_p=1-(1-raw_p)**9;run;
data w6717m(keep=metric value);set w6717o;length metric $120;array measured[*] bon_p sid_p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6717m;set w6717m;format value best32.;run;
proc export data=w6717m outfile="%sysfunc(pathname(work))/W6717.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6717;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6717:;quit;
