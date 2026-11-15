/* New workflow V6359; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6359i;
length grp $80;
grp='g1';c1=35.13;c2=-1.8;c3=-18.73;c4=60.34;c5=27.41;c6=-25.52;output;
grp='g2';c1=44.26;c2=61.33;c3=70.4;c4=-12.53;c5=44.54;c6=58.61;output;
grp='g3';c1=-14.61;c2=-12.54;c3=-10.469999999999999;c4=33.6;c5=3.67;c6=-26.259999999999998;output;
grp='g1';c1=6.52;c2=-22.41;c3=-25.34;c4=-28.27;c5=-4.2;c6=17.87;output;
grp='g2';c1=-27.35;c2=21.72;c3=27.79;c4=36.86;c5=38.93;c6=60.0;output;
grp='g3';c1=37.78;c2=26.85;c3=0.92;c4=36.99;c5=2.06;c6=22.130000000000003;output;
grp='g1';c1=38.91;c2=29.98;c3=52.05;c4=-24.88;c5=34.19;c6=2.2600000000000002;output;
grp='g2';c1=31.04;c2=24.11;c3=-4.82;c4=20.25;c5=49.32;c6=50.39;output;
run;
%n26_ApplyFunc_rowwide(dsdin=v6359i,row_keys=grp,KeyVar4dsdout=keygrp,Regex4col_vars2apply=^c,SQL_Fun4apply=mean,dsdout=v6359o);
data v6359m(keep=metric value);set v6359o;length metric $120;array measured[*] c1 c2 c3 c4 c5 c6;do _measure=1 to dim(measured);metric=catx(':',strip(keygrp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6359m;set v6359m;format value best32.;run;
proc export data=v6359m outfile="%sysfunc(pathname(work))/V6359.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6359;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6359:;quit;
