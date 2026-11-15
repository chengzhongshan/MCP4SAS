/* New workflow W6978; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6978i;
length grp $80;
grp='g1';amount=20.0;output;
grp='g2';amount=18.5;output;
grp='g3';amount=6.25;output;
grp='g1';amount=4.25;output;
grp='g2';amount=14.5;output;
grp='g3';amount=12.5;output;
grp='g1';amount=10.75;output;
grp='g2';amount=17.0;output;
grp='g3';amount=24.5;output;
grp='g1';amount=2.25;output;
grp='g2';amount=0.25;output;
grp='g3';amount=14.0;output;
run;
proc summary data=w6978i nway;class grp;var amount;output out=w6978o n=n sum=total mean=average min=smallest max=largest;run;
data w6978m(keep=metric value);set w6978o;length metric $120;array measured[*] n total average smallest largest;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6978m;set w6978m;format value best32.;run;
proc export data=w6978m outfile="%sysfunc(pathname(work))/W6978.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6978;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6978:;quit;
