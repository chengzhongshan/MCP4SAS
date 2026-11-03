/* F1989 failure_means_missing_variable, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1989a; do x=1 to 10; output; end; run;
proc means data=f1989a; var f1989absent; run;

proc datasets library=work nolist; delete f1989:; quit;
