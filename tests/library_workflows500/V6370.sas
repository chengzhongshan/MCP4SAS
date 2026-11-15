/* New workflow V6370; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6370i;
length grp $80;
grp='g1';c1=32.13;c2=11.200000000000001;output;
grp='g2';c1=-23.74;c2=-8.67;output;
grp='g3';c1=62.39;c2=67.46;output;
grp='g1';c1=-12.48;c2=48.59;output;
grp='g2';c1=10.65;c2=-13.28;output;
grp='g3';c1=22.78;c2=59.85;output;
run;
%n26_ApplyFunc_rowwide(dsdin=v6370i,row_keys=grp,KeyVar4dsdout=keygrp,Regex4col_vars2apply=^c,SQL_Fun4apply=sum,dsdout=v6370o);
data v6370m(keep=metric value);set v6370o;length metric $120;array measured[*] c1 c2;do _measure=1 to dim(measured);metric=catx(':',strip(keygrp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6370m;set v6370m;format value best32.;run;
proc export data=v6370m outfile="%sysfunc(pathname(work))/V6370.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6370;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6370:;quit;
