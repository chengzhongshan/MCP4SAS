/* New workflow V6347; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6347i;
length grp $80;
grp='g1';c1=2.13;c2=10.200000000000001;c3=10.270000000000001;c4=-17.66;output;
grp='g2';c1=39.26;c2=2.3299999999999996;c3=13.4;c4=39.47;output;
grp='g3';c1=-14.61;c2=49.46;c3=-24.47;c4=-25.4;output;
run;
%n26_ApplyFunc_rowwide(dsdin=v6347i,row_keys=grp,KeyVar4dsdout=keygrp,Regex4col_vars2apply=^c,SQL_Fun4apply=mean,dsdout=v6347o);
data v6347m(keep=metric value);set v6347o;length metric $120;array measured[*] c1 c2 c3 c4;do _measure=1 to dim(measured);metric=catx(':',strip(keygrp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6347m;set v6347m;format value best32.;run;
proc export data=v6347m outfile="%sysfunc(pathname(work))/V6347.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6347;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6347:;quit;
