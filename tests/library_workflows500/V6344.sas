/* New workflow V6344; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6344i;
length grp $80;
grp='g1';c1=-11.87;c2=65.19999999999999;c3=66.27;c4=9.340000000000002;c5=44.410000000000004;c6=44.480000000000004;output;
grp='g2';c1=29.26;c2=9.33;c3=-27.599999999999998;c4=68.47;c5=18.540000000000003;c6=19.610000000000003;output;
grp='g3';c1=19.39;c2=66.46;c3=13.530000000000001;c4=53.6;c5=-29.33;c6=-14.26;output;
grp='g1';c1=23.52;c2=18.59;c3=35.660000000000004;c4=-16.27;c5=70.8;c6=45.870000000000005;output;
grp='g2';c1=64.65;c2=69.72;c3=51.79;c4=56.86;c5=31.93;c6=5.551115123125783e-17;output;
grp='g3';c1=-10.22;c2=30.85;c3=-19.08;c4=64.99;c5=26.060000000000002;c6=23.130000000000003;output;
grp='g1';c1=70.91;c2=39.98;c3=58.05;c4=55.12;c5=20.19;c6=68.25999999999999;output;
run;
%n26_ApplyFunc_rowwide(dsdin=v6344i,row_keys=grp,KeyVar4dsdout=keygrp,Regex4col_vars2apply=^c,SQL_Fun4apply=mean,dsdout=v6344o);
data v6344m(keep=metric value);set v6344o;length metric $120;array measured[*] c1 c2 c3 c4 c5 c6;do _measure=1 to dim(measured);metric=catx(':',strip(keygrp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6344m;set v6344m;format value best32.;run;
proc export data=v6344m outfile="%sysfunc(pathname(work))/V6344.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6344;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6344:;quit;
