/* New workflow V6350; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6350i;
length grp $80;
grp='g1';c1=9.13;c2=64.19999999999999;output;
grp='g2';c1=23.26;c2=42.33;output;
grp='g3';c1=-21.61;c2=57.46;output;
grp='g1';c1=7.52;c2=69.58999999999999;output;
grp='g2';c1=9.65;c2=63.72;output;
grp='g3';c1=3.7800000000000002;c2=-6.1499999999999995;output;
run;
%n26_ApplyFunc_rowwide(dsdin=v6350i,row_keys=grp,KeyVar4dsdout=keygrp,Regex4col_vars2apply=^c,SQL_Fun4apply=mean,dsdout=v6350o);
data v6350m(keep=metric value);set v6350o;length metric $120;array measured[*] c1 c2;do _measure=1 to dim(measured);metric=catx(':',strip(keygrp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6350m;set v6350m;format value best32.;run;
proc export data=v6350m outfile="%sysfunc(pathname(work))/V6350.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6350;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6350:;quit;
