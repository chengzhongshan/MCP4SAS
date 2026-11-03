/* F1985 failure_means_missing_variable, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1985a; do x=1 to 6; output; end; run;
proc means data=f1985a; var f1985absent; run;

proc datasets library=work nolist; delete f1985:; quit;
