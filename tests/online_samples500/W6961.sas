/* New workflow W6961; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6961i;
length grp $80;
grp='g1';amount=10.5;output;
grp='g2';amount=14.75;output;
grp='g3';amount=5.5;output;
grp='g1';amount=23.5;output;
grp='g2';amount=22.5;output;
grp='g3';amount=18.25;output;
grp='g1';amount=4.0;output;
grp='g2';amount=12.25;output;
grp='g3';amount=16.75;output;
run;
proc summary data=w6961i nway;class grp;var amount;output out=w6961o n=n sum=total mean=average min=smallest max=largest;run;
data w6961m(keep=metric value);set w6961o;length metric $120;array measured[*] n total average smallest largest;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6961m;set w6961m;format value best32.;run;
proc export data=w6961m outfile="%sysfunc(pathname(work))/W6961.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6961;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6961:;quit;
