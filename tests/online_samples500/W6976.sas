/* New workflow W6976; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6976i;
length grp $80;
grp='g1';amount=21.25;output;
grp='g2';amount=23.0;output;
grp='g3';amount=4.0;output;
grp='g1';amount=20.75;output;
grp='g2';amount=3.5;output;
grp='g3';amount=7.5;output;
grp='g1';amount=22.75;output;
grp='g2';amount=12.0;output;
grp='g3';amount=-4.5;output;
grp='g1';amount=1.75;output;
run;
proc summary data=w6976i nway;class grp;var amount;output out=w6976o n=n sum=total mean=average min=smallest max=largest;run;
data w6976m(keep=metric value);set w6976o;length metric $120;array measured[*] n total average smallest largest;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6976m;set w6976m;format value best32.;run;
proc export data=w6976m outfile="%sysfunc(pathname(work))/W6976.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6976;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6976:;quit;
