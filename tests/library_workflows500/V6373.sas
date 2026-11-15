/* New workflow V6373; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6373i;
length grp $80;
grp='g1';c1=-7.87;c2=-11.799999999999999;c3=43.27;c4=41.34;c5=34.410000000000004;output;
grp='g2';c1=68.26;c2=-5.67;c3=-3.6;c4=-5.53;c5=18.540000000000003;output;
grp='g3';c1=9.39;c2=45.46;c3=21.53;c4=33.6;c5=44.67;output;
grp='g1';c1=-17.48;c2=45.59;c3=-11.34;c4=-2.27;c5=60.800000000000004;output;
grp='g2';c1=44.65;c2=43.72;c3=-28.21;c4=42.86;c5=68.93;output;
grp='g3';c1=42.78;c2=-17.15;c3=17.92;c4=-12.01;c5=37.06;output;
grp='g1';c1=14.91;c2=12.98;c3=-7.95;c4=9.120000000000001;c5=35.19;output;
grp='g2';c1=44.04;c2=34.11;c3=17.18;c4=49.25;c5=-24.68;output;
grp='g3';c1=21.17;c2=27.240000000000002;c3=61.31;c4=-24.619999999999997;c5=52.45;output;
run;
%n26_ApplyFunc_rowwide(dsdin=v6373i,row_keys=grp,KeyVar4dsdout=keygrp,Regex4col_vars2apply=^c,SQL_Fun4apply=sum,dsdout=v6373o);
data v6373m(keep=metric value);set v6373o;length metric $120;array measured[*] c1 c2 c3 c4 c5;do _measure=1 to dim(measured);metric=catx(':',strip(keygrp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6373m;set v6373m;format value best32.;run;
proc export data=v6373m outfile="%sysfunc(pathname(work))/V6373.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6373;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6373:;quit;
