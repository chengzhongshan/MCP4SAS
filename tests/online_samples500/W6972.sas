/* New workflow W6972; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6972i;
length grp $80;
grp='g1';amount=17.5;output;
grp='g2';amount=-1.25;output;
grp='g3';amount=4.5;output;
grp='g1';amount=-4.5;output;
grp='g2';amount=16.0;output;
grp='g3';amount=17.75;output;
grp='g1';amount=5.5;output;
grp='g2';amount=4.75;output;
grp='g3';amount=11.25;output;
grp='g1';amount=0.25;output;
grp='g2';amount=22.5;output;
grp='g3';amount=-3.5;output;
grp='g1';amount=0.5;output;
run;
proc summary data=w6972i nway;class grp;var amount;output out=w6972o n=n sum=total mean=average min=smallest max=largest;run;
data w6972m(keep=metric value);set w6972o;length metric $120;array measured[*] n total average smallest largest;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6972m;set w6972m;format value best32.;run;
proc export data=w6972m outfile="%sysfunc(pathname(work))/W6972.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6972;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6972:;quit;
