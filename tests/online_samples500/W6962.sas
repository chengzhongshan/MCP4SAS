/* New workflow W6962; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6962i;
length grp $80;
grp='g1';amount=12.75;output;
grp='g2';amount=22.0;output;
grp='g3';amount=10.25;output;
grp='g1';amount=21.0;output;
grp='g2';amount=8.0;output;
grp='g3';amount=15.75;output;
grp='g1';amount=1.5;output;
grp='g2';amount=6.75;output;
grp='g3';amount=10.75;output;
grp='g1';amount=3.0;output;
run;
proc summary data=w6962i nway;class grp;var amount;output out=w6962o n=n sum=total mean=average min=smallest max=largest;run;
data w6962m(keep=metric value);set w6962o;length metric $120;array measured[*] n total average smallest largest;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6962m;set w6962m;format value best32.;run;
proc export data=w6962m outfile="%sysfunc(pathname(work))/W6962.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6962;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6962:;quit;
