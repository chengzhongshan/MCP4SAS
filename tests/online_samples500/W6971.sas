/* New workflow W6971; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6971i;
length grp $80;
grp='g1';amount=4.0;output;
grp='g2';amount=-1.75;output;
grp='g3';amount=2.0;output;
grp='g1';amount=7.0;output;
grp='g2';amount=24.5;output;
grp='g3';amount=7.75;output;
grp='g1';amount=12.75;output;
grp='g2';amount=-4.75;output;
grp='g3';amount=20.25;output;
grp='g1';amount=8.5;output;
grp='g2';amount=16.0;output;
grp='g3';amount=-0.25;output;
run;
proc summary data=w6971i nway;class grp;var amount;output out=w6971o n=n sum=total mean=average min=smallest max=largest;run;
data w6971m(keep=metric value);set w6971o;length metric $120;array measured[*] n total average smallest largest;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6971m;set w6971m;format value best32.;run;
proc export data=w6971m outfile="%sysfunc(pathname(work))/W6971.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6971;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6971:;quit;
