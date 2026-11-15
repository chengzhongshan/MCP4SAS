/* New workflow V6375; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6375i;
length grp $80;
grp='g1';c1=-0.87;c2=-24.8;output;
grp='g2';c1=-21.74;c2=56.33;output;
grp='g3';c1=64.39;c2=-15.54;output;
grp='g1';c1=56.52;c2=-3.41;output;
run;
%n26_ApplyFunc_rowwide(dsdin=v6375i,row_keys=grp,KeyVar4dsdout=keygrp,Regex4col_vars2apply=^c,SQL_Fun4apply=sum,dsdout=v6375o);
data v6375m(keep=metric value);set v6375o;length metric $120;array measured[*] c1 c2;do _measure=1 to dim(measured);metric=catx(':',strip(keygrp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6375m;set v6375m;format value best32.;run;
proc export data=v6375m outfile="%sysfunc(pathname(work))/V6375.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6375;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6375:;quit;
