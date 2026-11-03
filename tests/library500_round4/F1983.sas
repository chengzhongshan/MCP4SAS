/* F1983 failure_means_missing_variable, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1983a; do x=1 to 4; output; end; run;
proc means data=f1983a; var f1983absent; run;

proc datasets library=work nolist; delete f1983:; quit;
