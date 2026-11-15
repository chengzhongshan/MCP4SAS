/* New workflow V6351; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6351i;
length grp $80;
grp='g1';c1=47.13;c2=41.2;c3=-2.73;output;
grp='g2';c1=32.26;c2=22.330000000000002;c3=30.400000000000002;output;
grp='g3';c1=6.39;c2=-23.54;c3=-1.4699999999999998;output;
grp='g1';c1=-23.48;c2=-2.41;c3=16.66;output;
grp='g2';c1=15.65;c2=35.72;c3=22.79;output;
grp='g3';c1=1.78;c2=-14.15;c3=16.92;output;
grp='g1';c1=-0.08999999999999997;c2=42.98;c3=55.05;output;
run;
%n26_ApplyFunc_rowwide(dsdin=v6351i,row_keys=grp,KeyVar4dsdout=keygrp,Regex4col_vars2apply=^c,SQL_Fun4apply=mean,dsdout=v6351o);
data v6351m(keep=metric value);set v6351o;length metric $120;array measured[*] c1 c2 c3;do _measure=1 to dim(measured);metric=catx(':',strip(keygrp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6351m;set v6351m;format value best32.;run;
proc export data=v6351m outfile="%sysfunc(pathname(work))/V6351.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6351;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6351:;quit;
