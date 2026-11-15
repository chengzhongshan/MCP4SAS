/* New workflow W6964; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6964i;
length grp $80;
grp='g1';amount=16.25;output;
grp='g2';amount=19.75;output;
grp='g3';amount=1.0;output;
grp='g1';amount=22.75;output;
grp='g2';amount=-0.75;output;
grp='g3';amount=13.0;output;
grp='g1';amount=17.75;output;
grp='g2';amount=11.75;output;
grp='g3';amount=6.0;output;
grp='g1';amount=13.75;output;
grp='g2';amount=-4.75;output;
grp='g3';amount=15.25;output;
run;
proc summary data=w6964i nway;class grp;var amount;output out=w6964o n=n sum=total mean=average min=smallest max=largest;run;
data w6964m(keep=metric value);set w6964o;length metric $120;array measured[*] n total average smallest largest;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6964m;set w6964m;format value best32.;run;
proc export data=w6964m outfile="%sysfunc(pathname(work))/W6964.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6964;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6964:;quit;
