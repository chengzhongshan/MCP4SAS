/* New workflow V6341; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6341i;
length grp $80;
grp='g1';c1=46.13;c2=51.2;c3=66.27;output;
grp='g2';c1=37.26;c2=45.33;c3=40.4;output;
grp='g3';c1=-15.61;c2=36.46;c3=2.5300000000000002;output;
grp='g1';c1=65.52;c2=47.59;c3=6.659999999999999;output;
run;
%n26_ApplyFunc_rowwide(dsdin=v6341i,row_keys=grp,KeyVar4dsdout=keygrp,Regex4col_vars2apply=^c,SQL_Fun4apply=mean,dsdout=v6341o);
data v6341m(keep=metric value);set v6341o;length metric $120;array measured[*] c1 c2 c3;do _measure=1 to dim(measured);metric=catx(':',strip(keygrp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6341m;set v6341m;format value best32.;run;
proc export data=v6341m outfile="%sysfunc(pathname(work))/V6341.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6341;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6341:;quit;
