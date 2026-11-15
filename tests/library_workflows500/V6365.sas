/* New workflow V6365; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6365i;
length grp $80;
grp='g1';c1=41.13;c2=21.2;output;
grp='g2';c1=61.26;c2=34.33;output;
grp='g3';c1=34.39;c2=46.46;output;
grp='g1';c1=-13.48;c2=-0.41;output;
grp='g2';c1=-9.35;c2=25.72;output;
grp='g3';c1=-28.22;c2=31.85;output;
grp='g1';c1=13.91;c2=66.97999999999999;output;
grp='g2';c1=21.04;c2=24.11;output;
run;
%n26_ApplyFunc_rowwide(dsdin=v6365i,row_keys=grp,KeyVar4dsdout=keygrp,Regex4col_vars2apply=^c,SQL_Fun4apply=sum,dsdout=v6365o);
data v6365m(keep=metric value);set v6365o;length metric $120;array measured[*] c1 c2;do _measure=1 to dim(measured);metric=catx(':',strip(keygrp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6365m;set v6365m;format value best32.;run;
proc export data=v6365m outfile="%sysfunc(pathname(work))/V6365.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6365;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6365:;quit;
