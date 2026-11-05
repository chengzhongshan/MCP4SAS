/* K4519 failure_classdata_type_mismatch, N=10; source: SAS Guide to Report Writing Examples, Version 6, First Edition.txt:985 */

data k4519a; grp=10; x=1; run; data k4519classes; length grp $8; grp='10'; run;
proc summary data=k4519a classdata=k4519classes nway; class grp; var x; output out=k4519b sum=total; run;

proc datasets library=work nolist; delete k4519:; quit;
