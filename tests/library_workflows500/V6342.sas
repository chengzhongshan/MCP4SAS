/* New workflow V6342; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6342i;
length grp $80;
grp='g1';c1=-24.87;c2=-13.799999999999999;c3=37.27;c4=26.34;output;
grp='g2';c1=8.26;c2=8.33;c3=-22.599999999999998;c4=-9.53;output;
grp='g3';c1=-11.61;c2=61.46;c3=-9.469999999999999;c4=-13.399999999999999;output;
grp='g1';c1=54.52;c2=6.59;c3=24.66;c4=31.73;output;
grp='g2';c1=5.65;c2=1.72;c3=-3.21;c4=15.860000000000001;output;
run;
%n26_ApplyFunc_rowwide(dsdin=v6342i,row_keys=grp,KeyVar4dsdout=keygrp,Regex4col_vars2apply=^c,SQL_Fun4apply=mean,dsdout=v6342o);
data v6342m(keep=metric value);set v6342o;length metric $120;array measured[*] c1 c2 c3 c4;do _measure=1 to dim(measured);metric=catx(':',strip(keygrp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6342m;set v6342m;format value best32.;run;
proc export data=v6342m outfile="%sysfunc(pathname(work))/V6342.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6342;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6342:;quit;
