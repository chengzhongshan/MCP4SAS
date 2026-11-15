/* New workflow V6346; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6346i;
length grp $80;
grp='g1';c1=-21.87;c2=1.2;c3=22.27;output;
grp='g2';c1=14.26;c2=18.330000000000002;c3=26.400000000000002;output;
grp='g3';c1=38.39;c2=42.46;c3=46.53;output;
grp='g1';c1=64.52;c2=50.59;c3=-18.34;output;
grp='g2';c1=-26.35;c2=68.72;c3=34.79;output;
grp='g3';c1=-23.22;c2=-25.15;c3=68.92;output;
grp='g1';c1=33.91;c2=8.98;c3=48.05;output;
grp='g2';c1=-7.96;c2=1.11;c3=24.18;output;
grp='g3';c1=9.17;c2=22.240000000000002;c3=20.310000000000002;output;
run;
%n26_ApplyFunc_rowwide(dsdin=v6346i,row_keys=grp,KeyVar4dsdout=keygrp,Regex4col_vars2apply=^c,SQL_Fun4apply=mean,dsdout=v6346o);
data v6346m(keep=metric value);set v6346o;length metric $120;array measured[*] c1 c2 c3;do _measure=1 to dim(measured);metric=catx(':',strip(keygrp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6346m;set v6346m;format value best32.;run;
proc export data=v6346m outfile="%sysfunc(pathname(work))/V6346.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6346;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6346:;quit;
