/* New workflow V6380; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6380i;
length grp $80;
grp='g1';c1=66.13;c2=56.2;output;
grp='g2';c1=-16.74;c2=43.33;output;
grp='g3';c1=3.39;c2=24.46;output;
grp='g1';c1=19.52;c2=38.59;output;
grp='g2';c1=56.65;c2=-9.28;output;
grp='g3';c1=-20.22;c2=42.85;output;
grp='g1';c1=59.91;c2=21.98;output;
grp='g2';c1=6.04;c2=-24.89;output;
grp='g3';c1=40.17;c2=56.24;output;
run;
%n26_ApplyFunc_rowwide(dsdin=v6380i,row_keys=grp,KeyVar4dsdout=keygrp,Regex4col_vars2apply=^c,SQL_Fun4apply=sum,dsdout=v6380o);
data v6380m(keep=metric value);set v6380o;length metric $120;array measured[*] c1 c2;do _measure=1 to dim(measured);metric=catx(':',strip(keygrp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6380m;set v6380m;format value best32.;run;
proc export data=v6380m outfile="%sysfunc(pathname(work))/V6380.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6380;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6380:;quit;
