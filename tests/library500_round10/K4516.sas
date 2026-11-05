/* K4516 failure_classdata_type_mismatch, N=7; source: SAS Guide to Report Writing Examples, Version 6, First Edition.txt:985 */

data k4516a; grp=7; x=1; run; data k4516classes; length grp $8; grp='7'; run;
proc summary data=k4516a classdata=k4516classes nway; class grp; var x; output out=k4516b sum=total; run;

proc datasets library=work nolist; delete k4516:; quit;
