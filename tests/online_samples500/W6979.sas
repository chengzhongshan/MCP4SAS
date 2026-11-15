/* New workflow W6979; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6979i;
length grp $80;
grp='g1';amount=-1.0;output;
grp='g2';amount=22.0;output;
grp='g3';amount=7.25;output;
grp='g1';amount=-4.5;output;
grp='g2';amount=-3.0;output;
grp='g3';amount=8.5;output;
grp='g1';amount=21.0;output;
grp='g2';amount=0.5;output;
grp='g3';amount=2.5;output;
grp='g1';amount=18.25;output;
grp='g2';amount=4.75;output;
grp='g3';amount=-0.5;output;
grp='g1';amount=18.75;output;
run;
proc summary data=w6979i nway;class grp;var amount;output out=w6979o n=n sum=total mean=average min=smallest max=largest;run;
data w6979m(keep=metric value);set w6979o;length metric $120;array measured[*] n total average smallest largest;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6979m;set w6979m;format value best32.;run;
proc export data=w6979m outfile="%sysfunc(pathname(work))/W6979.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6979;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6979:;quit;
