/* New workflow V6377; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6377i;
length grp $80;
grp='g1';c1=56.13;c2=70.19999999999999;c3=35.27;c4=46.34;output;
grp='g2';c1=62.26;c2=58.33;c3=-28.599999999999998;c4=11.47;output;
grp='g3';c1=44.39;c2=30.46;c3=60.53;c4=60.6;output;
grp='g1';c1=60.52;c2=53.59;c3=46.660000000000004;c4=-21.27;output;
grp='g2';c1=68.65;c2=42.72;c3=-28.21;c4=2.86;output;
grp='g3';c1=-15.22;c2=0.8500000000000001;c3=22.92;c4=-6.01;output;
run;
%n26_ApplyFunc_rowwide(dsdin=v6377i,row_keys=grp,KeyVar4dsdout=keygrp,Regex4col_vars2apply=^c,SQL_Fun4apply=sum,dsdout=v6377o);
data v6377m(keep=metric value);set v6377o;length metric $120;array measured[*] c1 c2 c3 c4;do _measure=1 to dim(measured);metric=catx(':',strip(keygrp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6377m;set v6377m;format value best32.;run;
proc export data=v6377m outfile="%sysfunc(pathname(work))/V6377.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6377;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6377:;quit;
