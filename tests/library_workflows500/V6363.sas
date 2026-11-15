/* New workflow V6363; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6363i;
length grp $80;
grp='g1';c1=39.13;c2=-22.8;c3=64.27;c4=67.33999999999999;c5=43.410000000000004;output;
grp='g2';c1=-24.74;c2=57.33;c3=-17.599999999999998;c4=47.47;c5=49.54;output;
grp='g3';c1=37.39;c2=46.46;c3=-12.469999999999999;c4=8.600000000000001;c5=-13.33;output;
grp='g1';c1=17.52;c2=33.59;c3=53.660000000000004;c4=67.72999999999999;c5=-0.19999999999999996;output;
grp='g2';c1=-8.35;c2=8.72;c3=0.79;c4=36.86;c5=-11.07;output;
grp='g3';c1=-2.2199999999999998;c2=62.85;c3=49.92;c4=3.99;c5=-26.939999999999998;output;
run;
%n26_ApplyFunc_rowwide(dsdin=v6363i,row_keys=grp,KeyVar4dsdout=keygrp,Regex4col_vars2apply=^c,SQL_Fun4apply=sum,dsdout=v6363o);
data v6363m(keep=metric value);set v6363o;length metric $120;array measured[*] c1 c2 c3 c4 c5;do _measure=1 to dim(measured);metric=catx(':',strip(keygrp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6363m;set v6363m;format value best32.;run;
proc export data=v6363m outfile="%sysfunc(pathname(work))/V6363.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6363;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6363:;quit;
