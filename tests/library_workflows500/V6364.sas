/* New workflow V6364; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6364i;
length grp $80;
grp='g1';c1=31.13;c2=15.200000000000001;c3=41.27;c4=24.34;c5=-0.59;c6=14.48;output;
grp='g2';c1=68.26;c2=-3.6700000000000004;c3=-4.6000000000000005;c4=58.47;c5=0.54;c6=2.61;output;
grp='g3';c1=-7.61;c2=-8.54;c3=13.530000000000001;c4=30.6;c5=37.67;c6=9.74;output;
grp='g1';c1=62.52;c2=2.59;c3=0.66;c4=47.730000000000004;c5=23.8;c6=-21.13;output;
grp='g2';c1=-13.35;c2=-0.27999999999999997;c3=15.790000000000001;c4=55.86;c5=19.93;c6=-13.0;output;
grp='g3';c1=13.78;c2=63.85;c3=7.92;c4=62.99;c5=34.06;c6=34.13;output;
grp='g1';c1=0.91;c2=-23.02;c3=53.05;c4=58.12;c5=-6.81;c6=13.26;output;
run;
%n26_ApplyFunc_rowwide(dsdin=v6364i,row_keys=grp,KeyVar4dsdout=keygrp,Regex4col_vars2apply=^c,SQL_Fun4apply=sum,dsdout=v6364o);
data v6364m(keep=metric value);set v6364o;length metric $120;array measured[*] c1 c2 c3 c4 c5 c6;do _measure=1 to dim(measured);metric=catx(':',strip(keygrp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6364m;set v6364m;format value best32.;run;
proc export data=v6364m outfile="%sysfunc(pathname(work))/V6364.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6364;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6364:;quit;
