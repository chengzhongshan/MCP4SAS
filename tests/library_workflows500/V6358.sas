/* New workflow V6358; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6358i;
length grp $80;
grp='g1';c1=47.13;c2=10.200000000000001;c3=-25.73;c4=59.34;c5=-8.59;output;
grp='g2';c1=39.26;c2=-17.669999999999998;c3=-20.599999999999998;c4=0.47000000000000003;c5=29.540000000000003;output;
grp='g3';c1=48.39;c2=11.46;c3=24.53;c4=23.6;c5=18.67;output;
grp='g1';c1=41.52;c2=35.59;c3=54.660000000000004;c4=-26.27;c5=-24.2;output;
grp='g2';c1=24.65;c2=7.720000000000001;c3=-28.21;c4=47.86;c5=36.93;output;
grp='g3';c1=31.78;c2=61.85;c3=-24.08;c4=-21.009999999999998;c5=-16.939999999999998;output;
grp='g1';c1=43.91;c2=45.98;c3=58.05;c4=-28.88;c5=-2.8099999999999996;output;
run;
%n26_ApplyFunc_rowwide(dsdin=v6358i,row_keys=grp,KeyVar4dsdout=keygrp,Regex4col_vars2apply=^c,SQL_Fun4apply=mean,dsdout=v6358o);
data v6358m(keep=metric value);set v6358o;length metric $120;array measured[*] c1 c2 c3 c4 c5;do _measure=1 to dim(measured);metric=catx(':',strip(keygrp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6358m;set v6358m;format value best32.;run;
proc export data=v6358m outfile="%sysfunc(pathname(work))/V6358.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6358;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6358:;quit;
