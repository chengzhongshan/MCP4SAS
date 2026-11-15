/* New workflow V6372; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6372i;
length grp $80;
grp='g1';c1=-25.87;c2=-7.8;c3=22.27;c4=-14.659999999999998;output;
grp='g2';c1=25.26;c2=59.33;c3=59.4;c4=-3.5300000000000002;output;
grp='g3';c1=27.39;c2=18.46;c3=29.53;c4=-8.399999999999999;output;
grp='g1';c1=14.52;c2=42.59;c3=40.660000000000004;c4=5.7299999999999995;output;
grp='g2';c1=-25.35;c2=-14.28;c3=26.79;c4=-20.14;output;
grp='g3';c1=68.78;c2=32.85;c3=60.92;c4=53.99;output;
grp='g1';c1=9.91;c2=-2.02;c3=2.0500000000000003;c4=15.120000000000001;output;
grp='g2';c1=68.04;c2=-19.89;c3=-25.82;c4=-22.75;output;
run;
%n26_ApplyFunc_rowwide(dsdin=v6372i,row_keys=grp,KeyVar4dsdout=keygrp,Regex4col_vars2apply=^c,SQL_Fun4apply=sum,dsdout=v6372o);
data v6372m(keep=metric value);set v6372o;length metric $120;array measured[*] c1 c2 c3 c4;do _measure=1 to dim(measured);metric=catx(':',strip(keygrp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6372m;set v6372m;format value best32.;run;
proc export data=v6372m outfile="%sysfunc(pathname(work))/V6372.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6372;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6372:;quit;
