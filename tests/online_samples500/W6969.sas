/* New workflow W6969; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6969i;
length grp $80;
grp='g1';amount=7.5;output;
grp='g2';amount=7.75;output;
grp='g3';amount=9.25;output;
grp='g1';amount=8.75;output;
grp='g2';amount=1.0;output;
grp='g3';amount=19.0;output;
grp='g1';amount=16.5;output;
grp='g2';amount=7.5;output;
grp='g3';amount=22.25;output;
grp='g1';amount=6.25;output;
run;
proc summary data=w6969i nway;class grp;var amount;output out=w6969o n=n sum=total mean=average min=smallest max=largest;run;
data w6969m(keep=metric value);set w6969o;length metric $120;array measured[*] n total average smallest largest;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6969m;set w6969m;format value best32.;run;
proc export data=w6969m outfile="%sysfunc(pathname(work))/W6969.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6969;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6969:;quit;
