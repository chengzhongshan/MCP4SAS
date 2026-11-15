/* New workflow W6965; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6965i;
length grp $80;
grp='g1';amount=-1.0;output;
grp='g2';amount=14.0;output;
grp='g3';amount=14.25;output;
grp='g1';amount=1.25;output;
grp='g2';amount=-0.25;output;
grp='g3';amount=10.5;output;
grp='g1';amount=3.5;output;
grp='g2';amount=-0.5;output;
grp='g3';amount=3.5;output;
grp='g1';amount=5.5;output;
grp='g2';amount=15.5;output;
grp='g3';amount=8.5;output;
grp='g1';amount=25.0;output;
run;
proc summary data=w6965i nway;class grp;var amount;output out=w6965o n=n sum=total mean=average min=smallest max=largest;run;
data w6965m(keep=metric value);set w6965o;length metric $120;array measured[*] n total average smallest largest;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6965m;set w6965m;format value best32.;run;
proc export data=w6965m outfile="%sysfunc(pathname(work))/W6965.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6965;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6965:;quit;
