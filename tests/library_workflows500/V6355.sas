/* New workflow V6355; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6355i;
length grp $80;
grp='g1';c1=30.13;c2=0.2;output;
grp='g2';c1=-17.74;c2=70.33;output;
grp='g3';c1=-9.61;c2=6.46;output;
grp='g1';c1=68.52;c2=-22.41;output;
run;
%n26_ApplyFunc_rowwide(dsdin=v6355i,row_keys=grp,KeyVar4dsdout=keygrp,Regex4col_vars2apply=^c,SQL_Fun4apply=mean,dsdout=v6355o);
data v6355m(keep=metric value);set v6355o;length metric $120;array measured[*] c1 c2;do _measure=1 to dim(measured);metric=catx(':',strip(keygrp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6355m;set v6355m;format value best32.;run;
proc export data=v6355m outfile="%sysfunc(pathname(work))/V6355.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6355;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6355:;quit;
