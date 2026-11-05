/* K4511 failure_classdata_type_mismatch, N=2; source: SAS Guide to Report Writing Examples, Version 6, First Edition.txt:985 */

data k4511a; grp=2; x=1; run; data k4511classes; length grp $8; grp='2'; run;
proc summary data=k4511a classdata=k4511classes nway; class grp; var x; output out=k4511b sum=total; run;

proc datasets library=work nolist; delete k4511:; quit;
