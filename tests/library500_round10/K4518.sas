/* K4518 failure_classdata_type_mismatch, N=9; source: SAS Guide to Report Writing Examples, Version 6, First Edition.txt:985 */

data k4518a; grp=9; x=1; run; data k4518classes; length grp $8; grp='9'; run;
proc summary data=k4518a classdata=k4518classes nway; class grp; var x; output out=k4518b sum=total; run;

proc datasets library=work nolist; delete k4518:; quit;
