/* F1987 failure_means_missing_variable, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1987a; do x=1 to 8; output; end; run;
proc means data=f1987a; var f1987absent; run;

proc datasets library=work nolist; delete f1987:; quit;
