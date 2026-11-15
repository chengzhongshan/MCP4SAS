/* New workflow V6371; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6371i;
length grp $80;
grp='g1';c1=-26.87;c2=-17.8;c3=39.27;output;
grp='g2';c1=-26.74;c2=20.330000000000002;c3=29.400000000000002;output;
grp='g3';c1=52.39;c2=50.46;c3=55.53;output;
grp='g1';c1=-13.48;c2=-5.41;c3=-20.34;output;
grp='g2';c1=4.65;c2=44.72;c3=66.79;output;
grp='g3';c1=45.78;c2=-20.15;c3=30.92;output;
grp='g1';c1=-9.09;c2=-5.02;c3=36.05;output;
run;
%n26_ApplyFunc_rowwide(dsdin=v6371i,row_keys=grp,KeyVar4dsdout=keygrp,Regex4col_vars2apply=^c,SQL_Fun4apply=sum,dsdout=v6371o);
data v6371m(keep=metric value);set v6371o;length metric $120;array measured[*] c1 c2 c3;do _measure=1 to dim(measured);metric=catx(':',strip(keygrp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6371m;set v6371m;format value best32.;run;
proc export data=v6371m outfile="%sysfunc(pathname(work))/V6371.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6371;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6371:;quit;
