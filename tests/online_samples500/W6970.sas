/* New workflow W6970; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6970i;
length grp $80;
grp='g1';amount=5.25;output;
grp='g2';amount=14.25;output;
grp='g3';amount=13.25;output;
grp='g1';amount=22.5;output;
grp='g2';amount=13.25;output;
grp='g3';amount=5.0;output;
grp='g1';amount=-3.25;output;
grp='g2';amount=-4.75;output;
grp='g3';amount=23.25;output;
grp='g1';amount=-4.0;output;
grp='g2';amount=6.0;output;
run;
proc summary data=w6970i nway;class grp;var amount;output out=w6970o n=n sum=total mean=average min=smallest max=largest;run;
data w6970m(keep=metric value);set w6970o;length metric $120;array measured[*] n total average smallest largest;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6970m;set w6970m;format value best32.;run;
proc export data=w6970m outfile="%sysfunc(pathname(work))/W6970.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6970;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6970:;quit;
