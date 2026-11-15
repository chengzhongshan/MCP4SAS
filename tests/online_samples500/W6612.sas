/* New workflow W6612; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6612i;
ne=44;nc=37;me=3.5;mc=0.5;se=1.6;sc=1.7000000000000002;output;
run;
%n26_compeff(w6612i,w6612o);run;
data w6612m(keep=metric value);set w6612o;length metric $120;array measured[*] estimate lower upper;do _measure=1 to dim(measured);metric=catx(':',strip(cats('type',type)),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6612m;set w6612m;format value best32.;run;
proc export data=w6612m outfile="%sysfunc(pathname(work))/W6612.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6612;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6612:;quit;
