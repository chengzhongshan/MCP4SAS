/* New workflow V6369; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6369i;
length grp $80;
grp='g1';c1=28.13;c2=41.2;c3=27.27;c4=-3.66;c5=0.41000000000000003;c6=63.480000000000004;output;
grp='g2';c1=17.26;c2=-13.67;c3=-1.6;c4=-9.53;c5=41.54;c6=9.61;output;
grp='g3';c1=22.39;c2=21.46;c3=-2.4699999999999998;c4=9.600000000000001;c5=40.67;c6=69.74;output;
grp='g1';c1=32.52;c2=70.58999999999999;c3=50.660000000000004;c4=45.730000000000004;c5=-20.2;c6=-10.13;output;
grp='g2';c1=23.65;c2=-8.28;c3=54.79;c4=-18.14;c5=-1.07;c6=-3.9999999999999996;output;
run;
%n26_ApplyFunc_rowwide(dsdin=v6369i,row_keys=grp,KeyVar4dsdout=keygrp,Regex4col_vars2apply=^c,SQL_Fun4apply=sum,dsdout=v6369o);
data v6369m(keep=metric value);set v6369o;length metric $120;array measured[*] c1 c2 c3 c4 c5 c6;do _measure=1 to dim(measured);metric=catx(':',strip(keygrp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6369m;set v6369m;format value best32.;run;
proc export data=v6369m outfile="%sysfunc(pathname(work))/V6369.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6369;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6369:;quit;
