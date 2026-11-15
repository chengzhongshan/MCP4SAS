/* New workflow W6977; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6977i;
length grp $80;
grp='g1';amount=5.25;output;
grp='g2';amount=0.0;output;
grp='g3';amount=18.0;output;
grp='g1';amount=23.5;output;
grp='g2';amount=21.5;output;
grp='g3';amount=15.25;output;
grp='g1';amount=19.75;output;
grp='g2';amount=17.0;output;
grp='g3';amount=4.5;output;
grp='g1';amount=17.25;output;
grp='g2';amount=1.25;output;
run;
proc summary data=w6977i nway;class grp;var amount;output out=w6977o n=n sum=total mean=average min=smallest max=largest;run;
data w6977m(keep=metric value);set w6977o;length metric $120;array measured[*] n total average smallest largest;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6977m;set w6977m;format value best32.;run;
proc export data=w6977m outfile="%sysfunc(pathname(work))/W6977.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6977;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6977:;quit;
