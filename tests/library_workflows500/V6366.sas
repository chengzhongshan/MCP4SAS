/* New workflow V6366; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6366i;
length grp $80;
grp='g1';c1=34.13;c2=56.2;c3=55.27;output;
grp='g2';c1=42.26;c2=42.33;c3=-19.599999999999998;output;
grp='g3';c1=60.39;c2=69.46;c3=-14.469999999999999;output;
grp='g1';c1=-8.48;c2=-16.41;c3=63.660000000000004;output;
grp='g2';c1=21.65;c2=8.72;c3=-20.21;output;
grp='g3';c1=25.78;c2=28.85;c3=18.92;output;
grp='g1';c1=43.91;c2=18.98;c3=38.05;output;
grp='g2';c1=34.04;c2=63.11;c3=20.18;output;
grp='g3';c1=59.17;c2=69.24;c3=12.31;output;
run;
%n26_ApplyFunc_rowwide(dsdin=v6366i,row_keys=grp,KeyVar4dsdout=keygrp,Regex4col_vars2apply=^c,SQL_Fun4apply=sum,dsdout=v6366o);
data v6366m(keep=metric value);set v6366o;length metric $120;array measured[*] c1 c2 c3;do _measure=1 to dim(measured);metric=catx(':',strip(keygrp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6366m;set v6366m;format value best32.;run;
proc export data=v6366m outfile="%sysfunc(pathname(work))/V6366.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6366;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6366:;quit;
