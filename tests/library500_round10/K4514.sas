/* K4514 failure_classdata_type_mismatch, N=5; source: SAS Guide to Report Writing Examples, Version 6, First Edition.txt:985 */

data k4514a; grp=5; x=1; run; data k4514classes; length grp $8; grp='5'; run;
proc summary data=k4514a classdata=k4514classes nway; class grp; var x; output out=k4514b sum=total; run;

proc datasets library=work nolist; delete k4514:; quit;
