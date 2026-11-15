/* New workflow V6362; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6362i;
length grp $80;
grp='g1';c1=5.13;c2=-28.8;c3=62.27;c4=-9.659999999999998;output;
grp='g2';c1=30.26;c2=-17.669999999999998;c3=-14.6;c4=32.47;output;
grp='g3';c1=-9.61;c2=49.46;c3=25.53;c4=65.6;output;
grp='g1';c1=19.52;c2=65.58999999999999;c3=49.660000000000004;c4=17.73;output;
grp='g2';c1=54.65;c2=-10.28;c3=0.79;c4=-9.139999999999999;output;
run;
%n26_ApplyFunc_rowwide(dsdin=v6362i,row_keys=grp,KeyVar4dsdout=keygrp,Regex4col_vars2apply=^c,SQL_Fun4apply=sum,dsdout=v6362o);
data v6362m(keep=metric value);set v6362o;length metric $120;array measured[*] c1 c2 c3 c4;do _measure=1 to dim(measured);metric=catx(':',strip(keygrp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6362m;set v6362m;format value best32.;run;
proc export data=v6362m outfile="%sysfunc(pathname(work))/V6362.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6362;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6362:;quit;
