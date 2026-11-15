/* New workflow V6353; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6353i;
length grp $80;
grp='g1';c1=-11.87;c2=51.2;c3=59.27;c4=9.340000000000002;c5=46.410000000000004;output;
grp='g2';c1=4.26;c2=-22.669999999999998;c3=11.4;c4=7.47;c5=37.54;output;
grp='g3';c1=-3.61;c2=12.46;c3=-9.469999999999999;c4=23.6;c5=45.67;output;
grp='g1';c1=56.52;c2=22.59;c3=6.659999999999999;c4=-0.26999999999999996;c5=61.800000000000004;output;
grp='g2';c1=48.65;c2=-15.28;c3=47.79;c4=-15.139999999999999;c5=52.93;output;
grp='g3';c1=13.78;c2=-10.15;c3=35.92;c4=-19.009999999999998;c5=68.06;output;
grp='g1';c1=16.91;c2=62.98;c3=58.05;c4=54.12;c5=9.19;output;
grp='g2';c1=-21.96;c2=40.11;c3=-18.82;c4=38.25;c5=-7.68;output;
grp='g3';c1=48.17;c2=5.24;c3=-4.69;c4=-1.62;c5=15.45;output;
run;
%n26_ApplyFunc_rowwide(dsdin=v6353i,row_keys=grp,KeyVar4dsdout=keygrp,Regex4col_vars2apply=^c,SQL_Fun4apply=mean,dsdout=v6353o);
data v6353m(keep=metric value);set v6353o;length metric $120;array measured[*] c1 c2 c3 c4 c5;do _measure=1 to dim(measured);metric=catx(':',strip(keygrp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6353m;set v6353m;format value best32.;run;
proc export data=v6353m outfile="%sysfunc(pathname(work))/V6353.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6353;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6353:;quit;
