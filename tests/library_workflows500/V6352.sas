/* New workflow V6352; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6352i;
length grp $80;
grp='g1';c1=-4.87;c2=39.2;c3=53.27;c4=62.34;output;
grp='g2';c1=58.26;c2=43.33;c3=-9.6;c4=-17.529999999999998;output;
grp='g3';c1=26.39;c2=28.46;c3=34.53;c4=30.6;output;
grp='g1';c1=17.52;c2=40.59;c3=-4.340000000000001;c4=52.730000000000004;output;
grp='g2';c1=-3.35;c2=-0.27999999999999997;c3=69.79;c4=42.86;output;
grp='g3';c1=35.78;c2=-22.15;c3=65.92;c4=47.99;output;
grp='g1';c1=31.91;c2=40.98;c3=35.05;c4=-8.879999999999999;output;
grp='g2';c1=-12.96;c2=47.11;c3=18.18;c4=68.25;output;
run;
%n26_ApplyFunc_rowwide(dsdin=v6352i,row_keys=grp,KeyVar4dsdout=keygrp,Regex4col_vars2apply=^c,SQL_Fun4apply=mean,dsdout=v6352o);
data v6352m(keep=metric value);set v6352o;length metric $120;array measured[*] c1 c2 c3 c4;do _measure=1 to dim(measured);metric=catx(':',strip(keygrp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6352m;set v6352m;format value best32.;run;
proc export data=v6352m outfile="%sysfunc(pathname(work))/V6352.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6352;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6352:;quit;
