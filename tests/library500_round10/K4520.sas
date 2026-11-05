/* K4520 failure_classdata_type_mismatch, N=11; source: SAS Guide to Report Writing Examples, Version 6, First Edition.txt:985 */

data k4520a; grp=11; x=1; run; data k4520classes; length grp $8; grp='11'; run;
proc summary data=k4520a classdata=k4520classes nway; class grp; var x; output out=k4520b sum=total; run;

proc datasets library=work nolist; delete k4520:; quit;
