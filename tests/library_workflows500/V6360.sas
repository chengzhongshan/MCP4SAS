/* New workflow V6360; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6360i;
length grp $80;
grp='g1';c1=12.13;c2=-23.8;output;
grp='g2';c1=32.26;c2=3.3299999999999996;output;
grp='g3';c1=2.39;c2=-16.54;output;
grp='g1';c1=-28.48;c2=0.5900000000000001;output;
grp='g2';c1=47.65;c2=38.72;output;
grp='g3';c1=18.78;c2=-10.15;output;
grp='g1';c1=0.91;c2=18.98;output;
grp='g2';c1=-15.96;c2=55.11;output;
grp='g3';c1=2.17;c2=-16.759999999999998;output;
run;
%n26_ApplyFunc_rowwide(dsdin=v6360i,row_keys=grp,KeyVar4dsdout=keygrp,Regex4col_vars2apply=^c,SQL_Fun4apply=mean,dsdout=v6360o);
data v6360m(keep=metric value);set v6360o;length metric $120;array measured[*] c1 c2;do _measure=1 to dim(measured);metric=catx(':',strip(keygrp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6360m;set v6360m;format value best32.;run;
proc export data=v6360m outfile="%sysfunc(pathname(work))/V6360.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6360;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6360:;quit;
