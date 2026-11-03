/* F1988 failure_means_missing_variable, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1988a; do x=1 to 9; output; end; run;
proc means data=f1988a; var f1988absent; run;

proc datasets library=work nolist; delete f1988:; quit;
