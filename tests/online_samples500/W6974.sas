/* New workflow W6974; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6974i;
length grp $80;
grp='g1';amount=3.5;output;
grp='g2';amount=23.0;output;
grp='g3';amount=24.25;output;
grp='g1';amount=10.25;output;
grp='g2';amount=-1.75;output;
grp='g3';amount=0.5;output;
grp='g1';amount=21.75;output;
grp='g2';amount=0.0;output;
run;
proc summary data=w6974i nway;class grp;var amount;output out=w6974o n=n sum=total mean=average min=smallest max=largest;run;
data w6974m(keep=metric value);set w6974o;length metric $120;array measured[*] n total average smallest largest;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6974m;set w6974m;format value best32.;run;
proc export data=w6974m outfile="%sysfunc(pathname(work))/W6974.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6974;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6974:;quit;
