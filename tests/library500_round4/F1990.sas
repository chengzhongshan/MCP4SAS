/* F1990 failure_means_missing_variable, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1990a; do x=1 to 11; output; end; run;
proc means data=f1990a; var f1990absent; run;

proc datasets library=work nolist; delete f1990:; quit;
