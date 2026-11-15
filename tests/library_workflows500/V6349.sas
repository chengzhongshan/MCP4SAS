/* New workflow V6349; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6349i;
length grp $80;
grp='g1';c1=69.13;c2=64.19999999999999;c3=37.27;c4=68.33999999999999;c5=-1.59;c6=36.480000000000004;output;
grp='g2';c1=-26.74;c2=18.330000000000002;c3=36.4;c4=7.47;c5=28.540000000000003;c6=36.61;output;
grp='g3';c1=-29.61;c2=69.46;c3=42.53;c4=35.6;c5=-10.33;c6=30.740000000000002;output;
grp='g1';c1=44.52;c2=-6.41;c3=22.66;c4=18.73;c5=-3.2;c6=-29.13;output;
grp='g2';c1=-23.35;c2=43.72;c3=34.79;c4=-20.14;c5=59.93;c6=1.0;output;
run;
%n26_ApplyFunc_rowwide(dsdin=v6349i,row_keys=grp,KeyVar4dsdout=keygrp,Regex4col_vars2apply=^c,SQL_Fun4apply=mean,dsdout=v6349o);
data v6349m(keep=metric value);set v6349o;length metric $120;array measured[*] c1 c2 c3 c4 c5 c6;do _measure=1 to dim(measured);metric=catx(':',strip(keygrp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6349m;set v6349m;format value best32.;run;
proc export data=v6349m outfile="%sysfunc(pathname(work))/V6349.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6349;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6349:;quit;
