/* New workflow W6975; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6975i;
length grp $80;
grp='g1';amount=5.0;output;
grp='g2';amount=9.75;output;
grp='g3';amount=-0.5;output;
grp='g1';amount=17.5;output;
grp='g2';amount=15.25;output;
grp='g3';amount=1.0;output;
grp='g1';amount=2.75;output;
grp='g2';amount=12.5;output;
grp='g3';amount=2.5;output;
run;
proc summary data=w6975i nway;class grp;var amount;output out=w6975o n=n sum=total mean=average min=smallest max=largest;run;
data w6975m(keep=metric value);set w6975o;length metric $120;array measured[*] n total average smallest largest;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6975m;set w6975m;format value best32.;run;
proc export data=w6975m outfile="%sysfunc(pathname(work))/W6975.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6975;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6975:;quit;
