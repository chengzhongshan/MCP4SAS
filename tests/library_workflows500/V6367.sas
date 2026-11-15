/* New workflow V6367; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6367i;
length grp $80;
grp='g1';c1=65.13;c2=-22.8;c3=9.270000000000001;c4=-26.66;output;
grp='g2';c1=-0.74;c2=3.3299999999999996;c3=-10.6;c4=70.47;output;
grp='g3';c1=42.39;c2=7.46;c3=68.53;c4=-9.399999999999999;output;
run;
%n26_ApplyFunc_rowwide(dsdin=v6367i,row_keys=grp,KeyVar4dsdout=keygrp,Regex4col_vars2apply=^c,SQL_Fun4apply=sum,dsdout=v6367o);
data v6367m(keep=metric value);set v6367o;length metric $120;array measured[*] c1 c2 c3 c4;do _measure=1 to dim(measured);metric=catx(':',strip(keygrp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6367m;set v6367m;format value best32.;run;
proc export data=v6367m outfile="%sysfunc(pathname(work))/V6367.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6367;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6367:;quit;
