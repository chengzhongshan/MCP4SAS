/* K4515 failure_classdata_type_mismatch, N=6; source: SAS Guide to Report Writing Examples, Version 6, First Edition.txt:985 */

data k4515a; grp=6; x=1; run; data k4515classes; length grp $8; grp='6'; run;
proc summary data=k4515a classdata=k4515classes nway; class grp; var x; output out=k4515b sum=total; run;

proc datasets library=work nolist; delete k4515:; quit;
