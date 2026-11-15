/* New workflow V6345; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6345i;
length grp $80;
grp='g1';c1=37.13;c2=70.19999999999999;output;
grp='g2';c1=23.26;c2=14.33;output;
grp='g3';c1=-1.6099999999999999;c2=17.46;output;
grp='g1';c1=49.52;c2=-21.41;output;
grp='g2';c1=29.65;c2=-18.28;output;
grp='g3';c1=61.78;c2=54.85;output;
grp='g1';c1=-4.09;c2=42.98;output;
grp='g2';c1=38.04;c2=71.11;output;
run;
%n26_ApplyFunc_rowwide(dsdin=v6345i,row_keys=grp,KeyVar4dsdout=keygrp,Regex4col_vars2apply=^c,SQL_Fun4apply=mean,dsdout=v6345o);
data v6345m(keep=metric value);set v6345o;length metric $120;array measured[*] c1 c2;do _measure=1 to dim(measured);metric=catx(':',strip(keygrp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6345m;set v6345m;format value best32.;run;
proc export data=v6345m outfile="%sysfunc(pathname(work))/V6345.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6345;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6345:;quit;
