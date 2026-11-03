/* F1986 failure_means_missing_variable, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1986a; do x=1 to 7; output; end; run;
proc means data=f1986a; var f1986absent; run;

proc datasets library=work nolist; delete f1986:; quit;
