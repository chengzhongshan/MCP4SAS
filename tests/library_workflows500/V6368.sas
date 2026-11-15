/* New workflow V6368; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6368i;
length grp $80;
grp='g1';c1=-13.87;c2=-23.8;c3=35.27;c4=38.34;c5=38.410000000000004;output;
grp='g2';c1=-11.74;c2=-20.669999999999998;c3=-17.599999999999998;c4=28.470000000000002;c5=65.54;output;
grp='g3';c1=-0.61;c2=43.46;c3=32.53;c4=8.600000000000001;c5=43.67;output;
grp='g1';c1=37.52;c2=20.59;c3=-28.34;c4=-26.27;c5=13.799999999999999;output;
run;
%n26_ApplyFunc_rowwide(dsdin=v6368i,row_keys=grp,KeyVar4dsdout=keygrp,Regex4col_vars2apply=^c,SQL_Fun4apply=sum,dsdout=v6368o);
data v6368m(keep=metric value);set v6368o;length metric $120;array measured[*] c1 c2 c3 c4 c5;do _measure=1 to dim(measured);metric=catx(':',strip(keygrp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6368m;set v6368m;format value best32.;run;
proc export data=v6368m outfile="%sysfunc(pathname(work))/V6368.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6368;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6368:;quit;
