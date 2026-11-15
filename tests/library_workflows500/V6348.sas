/* New workflow V6348; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6348i;
length grp $80;
grp='g1';c1=34.13;c2=-24.8;c3=19.27;c4=34.34;c5=29.41;output;
grp='g2';c1=35.26;c2=2.3299999999999996;c3=-6.6000000000000005;c4=-17.529999999999998;c5=11.54;output;
grp='g3';c1=-21.61;c2=-29.54;c3=16.53;c4=70.6;c5=22.67;output;
grp='g1';c1=-7.48;c2=25.59;c3=58.660000000000004;c4=18.73;c5=48.800000000000004;output;
run;
%n26_ApplyFunc_rowwide(dsdin=v6348i,row_keys=grp,KeyVar4dsdout=keygrp,Regex4col_vars2apply=^c,SQL_Fun4apply=mean,dsdout=v6348o);
data v6348m(keep=metric value);set v6348o;length metric $120;array measured[*] c1 c2 c3 c4 c5;do _measure=1 to dim(measured);metric=catx(':',strip(keygrp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6348m;set v6348m;format value best32.;run;
proc export data=v6348m outfile="%sysfunc(pathname(work))/V6348.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6348;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6348:;quit;
