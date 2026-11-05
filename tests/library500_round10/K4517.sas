/* K4517 failure_classdata_type_mismatch, N=8; source: SAS Guide to Report Writing Examples, Version 6, First Edition.txt:985 */

data k4517a; grp=8; x=1; run; data k4517classes; length grp $8; grp='8'; run;
proc summary data=k4517a classdata=k4517classes nway; class grp; var x; output out=k4517b sum=total; run;

proc datasets library=work nolist; delete k4517:; quit;
