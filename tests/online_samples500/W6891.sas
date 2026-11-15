/* New workflow W6891; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6891i;
p=0.6868900147921295;output;
p=0.09971338746835924;output;
p=0.5647490754950495;output;
p=0.6205992953825572;output;
p=0.21187340220585418;output;
p=0.07499612619728793;output;
p=0.6970735224340153;output;
run;
proc sql;create table w6891o as select "combined" as gene,-2*sum(log(p)) as statistic,2*count(*) as df from w6891i;quit;data w6891o;set w6891o;p=1-probchi(statistic,df);run;
data w6891m(keep=metric value);set w6891o;length metric $120;array measured[*] statistic df p;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6891m;set w6891m;format value best32.;run;
proc export data=w6891m outfile="%sysfunc(pathname(work))/W6891.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6891;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6891:;quit;
