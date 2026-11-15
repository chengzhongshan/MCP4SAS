/* New workflow V6374; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6374i;
length grp $80;
grp='g1';c1=50.13;c2=20.2;c3=24.27;c4=0.34;c5=41.410000000000004;c6=-11.52;output;
grp='g2';c1=67.26;c2=29.330000000000002;c3=5.3999999999999995;c4=16.470000000000002;c5=-3.46;c6=32.61;output;
grp='g3';c1=63.39;c2=52.46;c3=33.53;c4=69.6;c5=2.67;c6=21.740000000000002;output;
run;
%n26_ApplyFunc_rowwide(dsdin=v6374i,row_keys=grp,KeyVar4dsdout=keygrp,Regex4col_vars2apply=^c,SQL_Fun4apply=sum,dsdout=v6374o);
data v6374m(keep=metric value);set v6374o;length metric $120;array measured[*] c1 c2 c3 c4 c5 c6;do _measure=1 to dim(measured);metric=catx(':',strip(keygrp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6374m;set v6374m;format value best32.;run;
proc export data=v6374m outfile="%sysfunc(pathname(work))/V6374.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6374;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6374:;quit;
