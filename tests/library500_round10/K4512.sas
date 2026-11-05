/* K4512 failure_classdata_type_mismatch, N=3; source: SAS Guide to Report Writing Examples, Version 6, First Edition.txt:985 */

data k4512a; grp=3; x=1; run; data k4512classes; length grp $8; grp='3'; run;
proc summary data=k4512a classdata=k4512classes nway; class grp; var x; output out=k4512b sum=total; run;

proc datasets library=work nolist; delete k4512:; quit;
