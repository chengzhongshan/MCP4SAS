/* F1981 failure_means_missing_variable, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1981a; do x=1 to 2; output; end; run;
proc means data=f1981a; var f1981absent; run;

proc datasets library=work nolist; delete f1981:; quit;
