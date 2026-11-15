/* New workflow W6968; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6968i;
length grp $80;
grp='g1';amount=1.5;output;
grp='g2';amount=9.5;output;
grp='g3';amount=21.25;output;
grp='g1';amount=-2.25;output;
grp='g2';amount=20.25;output;
grp='g3';amount=9.25;output;
grp='g1';amount=6.5;output;
grp='g2';amount=0.5;output;
grp='g3';amount=-1.5;output;
run;
proc summary data=w6968i nway;class grp;var amount;output out=w6968o n=n sum=total mean=average min=smallest max=largest;run;
data w6968m(keep=metric value);set w6968o;length metric $120;array measured[*] n total average smallest largest;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6968m;set w6968m;format value best32.;run;
proc export data=w6968m outfile="%sysfunc(pathname(work))/W6968.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6968;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6968:;quit;
