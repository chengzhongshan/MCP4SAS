/* K4513 failure_classdata_type_mismatch, N=4; source: SAS Guide to Report Writing Examples, Version 6, First Edition.txt:985 */

data k4513a; grp=4; x=1; run; data k4513classes; length grp $8; grp='4'; run;
proc summary data=k4513a classdata=k4513classes nway; class grp; var x; output out=k4513b sum=total; run;

proc datasets library=work nolist; delete k4513:; quit;
