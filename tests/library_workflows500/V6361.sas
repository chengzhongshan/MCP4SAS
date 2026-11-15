/* New workflow V6361; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6361i;
length grp $80;
grp='g1';c1=-6.87;c2=47.2;c3=18.27;output;
grp='g2';c1=-23.74;c2=-1.67;c3=49.4;output;
grp='g3';c1=14.39;c2=-5.54;c3=-0.47;output;
grp='g1';c1=33.52;c2=11.59;c3=-3.34;output;
run;
%n26_ApplyFunc_rowwide(dsdin=v6361i,row_keys=grp,KeyVar4dsdout=keygrp,Regex4col_vars2apply=^c,SQL_Fun4apply=sum,dsdout=v6361o);
data v6361m(keep=metric value);set v6361o;length metric $120;array measured[*] c1 c2 c3;do _measure=1 to dim(measured);metric=catx(':',strip(keygrp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6361m;set v6361m;format value best32.;run;
proc export data=v6361m outfile="%sysfunc(pathname(work))/V6361.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6361;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6361:;quit;
