/* New workflow V6379; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6379i;
length grp $80;
grp='g1';c1=65.13;c2=-9.799999999999999;c3=57.27;c4=20.34;c5=17.41;c6=-6.5200000000000005;output;
grp='g2';c1=14.26;c2=54.33;c3=-24.599999999999998;c4=37.47;c5=-22.459999999999997;c6=54.61;output;
grp='g3';c1=-28.61;c2=39.46;c3=41.53;c4=-18.4;c5=34.67;c6=63.74;output;
grp='g1';c1=27.52;c2=55.59;c3=60.660000000000004;c4=-17.27;c5=10.799999999999999;c6=-25.13;output;
grp='g2';c1=36.65;c2=4.720000000000001;c3=61.79;c4=55.86;c5=38.93;c6=52.0;output;
grp='g3';c1=6.78;c2=21.85;c3=-29.08;c4=12.99;c5=-18.939999999999998;c6=-17.869999999999997;output;
grp='g1';c1=52.91;c2=60.98;c3=36.05;c4=1.12;c5=67.19;c6=57.26;output;
grp='g2';c1=8.04;c2=24.11;c3=67.18;c4=26.25;c5=2.3200000000000003;c6=60.39;output;
run;
%n26_ApplyFunc_rowwide(dsdin=v6379i,row_keys=grp,KeyVar4dsdout=keygrp,Regex4col_vars2apply=^c,SQL_Fun4apply=sum,dsdout=v6379o);
data v6379m(keep=metric value);set v6379o;length metric $120;array measured[*] c1 c2 c3 c4 c5 c6;do _measure=1 to dim(measured);metric=catx(':',strip(keygrp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6379m;set v6379m;format value best32.;run;
proc export data=v6379m outfile="%sysfunc(pathname(work))/V6379.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6379;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6379:;quit;
