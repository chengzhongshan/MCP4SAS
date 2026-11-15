/* New workflow W6966; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6966i;
length grp $80;
grp='g1';amount=11.5;output;
grp='g2';amount=3.0;output;
grp='g3';amount=12.25;output;
grp='g1';amount=10.5;output;
grp='g2';amount=20.75;output;
grp='g3';amount=19.75;output;
grp='g1';amount=-1.25;output;
grp='g2';amount=7.5;output;
grp='g3';amount=16.25;output;
grp='g1';amount=4.5;output;
grp='g2';amount=7.5;output;
grp='g3';amount=6.0;output;
grp='g1';amount=0.75;output;
grp='g2';amount=22.25;output;
run;
proc summary data=w6966i nway;class grp;var amount;output out=w6966o n=n sum=total mean=average min=smallest max=largest;run;
data w6966m(keep=metric value);set w6966o;length metric $120;array measured[*] n total average smallest largest;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6966m;set w6966m;format value best32.;run;
proc export data=w6966m outfile="%sysfunc(pathname(work))/W6966.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6966;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6966:;quit;
