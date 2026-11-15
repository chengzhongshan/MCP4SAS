/* New workflow V6356; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6356i;
length grp $80;
grp='g1';c1=37.13;c2=61.2;c3=-11.729999999999999;output;
grp='g2';c1=-24.74;c2=34.33;c3=48.4;output;
grp='g3';c1=53.39;c2=-13.54;c3=40.53;output;
grp='g1';c1=5.52;c2=28.59;c3=35.660000000000004;output;
grp='g2';c1=55.65;c2=16.72;c3=34.79;output;
run;
%n26_ApplyFunc_rowwide(dsdin=v6356i,row_keys=grp,KeyVar4dsdout=keygrp,Regex4col_vars2apply=^c,SQL_Fun4apply=mean,dsdout=v6356o);
data v6356m(keep=metric value);set v6356o;length metric $120;array measured[*] c1 c2 c3;do _measure=1 to dim(measured);metric=catx(':',strip(keygrp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6356m;set v6356m;format value best32.;run;
proc export data=v6356m outfile="%sysfunc(pathname(work))/V6356.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6356;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6356:;quit;
