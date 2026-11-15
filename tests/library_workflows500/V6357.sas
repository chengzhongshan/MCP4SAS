/* New workflow V6357; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6357i;
length grp $80;
grp='g1';c1=31.13;c2=30.2;c3=69.27;c4=13.340000000000002;output;
grp='g2';c1=19.26;c2=34.33;c3=63.4;c4=5.47;output;
grp='g3';c1=33.39;c2=-1.5399999999999998;c3=60.53;c4=2.6;output;
grp='g1';c1=2.52;c2=7.59;c3=33.660000000000004;c4=30.73;output;
grp='g2';c1=65.65;c2=-11.28;c3=28.79;c4=-15.139999999999999;output;
grp='g3';c1=39.78;c2=66.85;c3=70.92;c4=53.99;output;
run;
%n26_ApplyFunc_rowwide(dsdin=v6357i,row_keys=grp,KeyVar4dsdout=keygrp,Regex4col_vars2apply=^c,SQL_Fun4apply=mean,dsdout=v6357o);
data v6357m(keep=metric value);set v6357o;length metric $120;array measured[*] c1 c2 c3 c4;do _measure=1 to dim(measured);metric=catx(':',strip(keygrp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6357m;set v6357m;format value best32.;run;
proc export data=v6357m outfile="%sysfunc(pathname(work))/V6357.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6357;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6357:;quit;
