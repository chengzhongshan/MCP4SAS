/* New workflow V6376; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6376i;
length grp $80;
grp='g1';c1=-5.87;c2=15.200000000000001;c3=-29.73;output;
grp='g2';c1=62.26;c2=51.33;c3=-3.6;output;
grp='g3';c1=26.39;c2=26.46;c3=-3.4699999999999998;output;
grp='g1';c1=-3.48;c2=-22.41;c3=13.66;output;
grp='g2';c1=10.65;c2=61.72;c3=-18.21;output;
run;
%n26_ApplyFunc_rowwide(dsdin=v6376i,row_keys=grp,KeyVar4dsdout=keygrp,Regex4col_vars2apply=^c,SQL_Fun4apply=sum,dsdout=v6376o);
data v6376m(keep=metric value);set v6376o;length metric $120;array measured[*] c1 c2 c3;do _measure=1 to dim(measured);metric=catx(':',strip(keygrp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6376m;set v6376m;format value best32.;run;
proc export data=v6376m outfile="%sysfunc(pathname(work))/V6376.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6376;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6376:;quit;
