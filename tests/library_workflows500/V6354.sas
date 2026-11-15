/* New workflow V6354; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6354i;
length grp $80;
grp='g1';c1=63.13;c2=31.2;c3=7.27;c4=36.34;c5=2.41;c6=66.47999999999999;output;
grp='g2';c1=12.26;c2=17.330000000000002;c3=5.3999999999999995;c4=-12.53;c5=47.54;c6=-12.39;output;
grp='g3';c1=4.39;c2=49.46;c3=30.53;c4=-3.4;c5=30.67;c6=-27.259999999999998;output;
run;
%n26_ApplyFunc_rowwide(dsdin=v6354i,row_keys=grp,KeyVar4dsdout=keygrp,Regex4col_vars2apply=^c,SQL_Fun4apply=mean,dsdout=v6354o);
data v6354m(keep=metric value);set v6354o;length metric $120;array measured[*] c1 c2 c3 c4 c5 c6;do _measure=1 to dim(measured);metric=catx(':',strip(keygrp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6354m;set v6354m;format value best32.;run;
proc export data=v6354m outfile="%sysfunc(pathname(work))/V6354.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6354;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6354:;quit;
