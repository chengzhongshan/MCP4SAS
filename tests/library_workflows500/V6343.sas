/* New workflow V6343; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6343i;
length grp $80;
grp='g1';c1=-25.87;c2=5.2;c3=-2.73;c4=-25.66;c5=15.41;output;
grp='g2';c1=16.26;c2=20.330000000000002;c3=9.4;c4=6.47;c5=31.540000000000003;output;
grp='g3';c1=-23.61;c2=51.46;c3=67.53;c4=18.6;c5=59.67;output;
grp='g1';c1=11.52;c2=8.59;c3=-25.34;c4=15.73;c5=64.8;output;
grp='g2';c1=-26.35;c2=-0.27999999999999997;c3=-18.21;c4=27.86;c5=51.93;output;
grp='g3';c1=52.78;c2=-28.15;c3=17.92;c4=-26.009999999999998;c5=-7.94;output;
run;
%n26_ApplyFunc_rowwide(dsdin=v6343i,row_keys=grp,KeyVar4dsdout=keygrp,Regex4col_vars2apply=^c,SQL_Fun4apply=mean,dsdout=v6343o);
data v6343m(keep=metric value);set v6343o;length metric $120;array measured[*] c1 c2 c3 c4 c5;do _measure=1 to dim(measured);metric=catx(':',strip(keygrp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6343m;set v6343m;format value best32.;run;
proc export data=v6343m outfile="%sysfunc(pathname(work))/V6343.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6343;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6343:;quit;
