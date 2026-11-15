/* New workflow V6378; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6378i;
length grp $80;
grp='g1';c1=-7.87;c2=-7.8;c3=19.27;c4=39.34;c5=-4.59;output;
grp='g2';c1=-2.74;c2=59.33;c3=-13.6;c4=34.47;c5=9.54;output;
grp='g3';c1=35.39;c2=-11.54;c3=1.5300000000000002;c4=18.6;c5=55.67;output;
grp='g1';c1=-14.48;c2=69.58999999999999;c3=-5.340000000000001;c4=20.73;c5=-21.2;output;
grp='g2';c1=6.65;c2=58.72;c3=56.79;c4=-24.14;c5=-26.07;output;
grp='g3';c1=13.78;c2=62.85;c3=35.92;c4=-28.009999999999998;c5=34.06;output;
grp='g1';c1=-1.0899999999999999;c2=47.98;c3=-17.95;c4=17.12;c5=13.19;output;
run;
%n26_ApplyFunc_rowwide(dsdin=v6378i,row_keys=grp,KeyVar4dsdout=keygrp,Regex4col_vars2apply=^c,SQL_Fun4apply=sum,dsdout=v6378o);
data v6378m(keep=metric value);set v6378o;length metric $120;array measured[*] c1 c2 c3 c4 c5;do _measure=1 to dim(measured);metric=catx(':',strip(keygrp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6378m;set v6378m;format value best32.;run;
proc export data=v6378m outfile="%sysfunc(pathname(work))/V6378.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6378;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6378:;quit;
