/* New workflow W6973; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6973i;
length grp $80;
grp='g1';amount=6.25;output;
grp='g2';amount=24.25;output;
grp='g3';amount=24.5;output;
grp='g1';amount=11.25;output;
grp='g2';amount=1.75;output;
grp='g3';amount=7.25;output;
grp='g1';amount=2.75;output;
grp='g2';amount=-4.75;output;
grp='g3';amount=-3.0;output;
grp='g1';amount=8.75;output;
grp='g2';amount=-1.75;output;
grp='g3';amount=21.75;output;
grp='g1';amount=4.75;output;
grp='g2';amount=-2.25;output;
run;
proc summary data=w6973i nway;class grp;var amount;output out=w6973o n=n sum=total mean=average min=smallest max=largest;run;
data w6973m(keep=metric value);set w6973o;length metric $120;array measured[*] n total average smallest largest;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6973m;set w6973m;format value best32.;run;
proc export data=w6973m outfile="%sysfunc(pathname(work))/W6973.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6973;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6973:;quit;
