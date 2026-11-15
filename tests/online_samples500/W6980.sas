/* New workflow W6980; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6980i;
length grp $80;
grp='g1';amount=12.25;output;
grp='g2';amount=21.5;output;
grp='g3';amount=-4.5;output;
grp='g1';amount=24.75;output;
grp='g2';amount=17.5;output;
grp='g3';amount=4.5;output;
grp='g1';amount=-2.5;output;
grp='g2';amount=7.0;output;
grp='g3';amount=21.0;output;
grp='g1';amount=24.5;output;
grp='g2';amount=16.25;output;
grp='g3';amount=3.25;output;
grp='g1';amount=10.5;output;
grp='g2';amount=16.75;output;
run;
proc summary data=w6980i nway;class grp;var amount;output out=w6980o n=n sum=total mean=average min=smallest max=largest;run;
data w6980m(keep=metric value);set w6980o;length metric $120;array measured[*] n total average smallest largest;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6980m;set w6980m;format value best32.;run;
proc export data=w6980m outfile="%sysfunc(pathname(work))/W6980.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6980;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6980:;quit;
