/* New workflow W6963; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6963i;
length grp $80;
grp='g1';amount=18.25;output;
grp='g2';amount=4.75;output;
grp='g3';amount=22.75;output;
grp='g1';amount=1.25;output;
grp='g2';amount=18.5;output;
grp='g3';amount=17.5;output;
grp='g1';amount=3.5;output;
grp='g2';amount=7.75;output;
grp='g3';amount=6.0;output;
grp='g1';amount=3.25;output;
grp='g2';amount=2.0;output;
run;
proc summary data=w6963i nway;class grp;var amount;output out=w6963o n=n sum=total mean=average min=smallest max=largest;run;
data w6963m(keep=metric value);set w6963o;length metric $120;array measured[*] n total average smallest largest;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6963m;set w6963m;format value best32.;run;
proc export data=w6963m outfile="%sysfunc(pathname(work))/W6963.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6963;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6963:;quit;
